% Coded by GaoHang / YuXiaoyang
% Soft Updata Log
% 200624:����Autosar����
% 200630:��д��������õĺ���
% on matlab R2018b
% ��ز�������
% ----------------------------------------%

%% ����Matlab������ļ�����Ӻ���Ŀ¼
eval('clear all');
close all;
clc;
addpath('D:\BaiduNetdiskDownload\MatlabWorkSpace\Project\lib'); % ���ߺ���Ŀ¼
run Rte_Type; % Load Rte_Type to WorkSpace

PARAM_SET_AUTO = 1; % �Զ�����I/Oģ���������ͺͳ���(0�����ã������ֶ����ã�1�����excel���ɣ�
if PARAM_SET_AUTO ~= 1
    fprintf('[WARNING]:Warning!�Զ�����I/O�ӿ������Լ��ӿڳ��ȹ��ܹر�\n');
end

%% Find/get excel file name,get I/O�ӿ�˵����.
SearchCondi = '*.xls*';
FilePath = GetFileName(0,SearchCondi); % ��ȡExcel�ļ������� mode=1 �Զ�������mode=2ͨ��matalb UIѡȡ

%% ��ȡ�������
InColRange = "A:G";
OutColRange = "A:G";
InSize = [2, 2];    % �������нӿ�������ʼλ��
OutSize= [2, 2];    % �������нӿ�������ʼλ��

% ��ȡInport��Outport��Excel����
InputTable = ReadIO(FilePath,1,InColRange);
OutputTable = ReadIO(FilePath,2,OutColRange);   % ��ȡ�������
[TruthInport,   InPortNum] = GetTruthTable( InputTable, InSize);
[TruthOutport, OutPortNum] = GetTruthTable(OutputTable,OutSize);
fprintf("[LOG] Inport Numbers:\t%d\n", InPortNum);
fprintf("[LOG]Outport Numbers:\t%d\n",OutPortNum);

% ����Inport/Outport��ȡ���轨��SWC����
module_name = GetModuleName(TruthOutport, OutSize(2)); % ��ȡģ������
subsyst_name = strcat(module_name, '/', module_name);
fprintf('[LOG]SWC full path:\t %s \n', subsyst_name);

%% ����Simulinkģ���ļ�
% ����:�����ļ�->����Simulink����->�����ϵͳ->��Ӹ�Port(I/O)
% ����Ƿ��Ѵ�ͬ���ļ������Ѿ���ͬ���ļ�
% ����:JABS/JABS�Ѿ��򿪣������ΪJABS/JABS_AutoSve_Data
try
    warning('off');     % �ر�warning�󣬽��Ѵ򿪵�ģ�����Ϊ
    newfile = strcat(module_name, '_AutoSave_', datestr(now, 'yyyymmdd_HHMM'));
    close_system(module_name, newfile);
    fprintf('[LOG]���Ѵ򿪵�ģ��[%s.slx ]�ļ����Ϊ[%s.slx ]\n', module_name, newfile);
    warning('on');
catch
end
% ����ģ��&��ģ��
new_system(module_name);
open_system(module_name);           % �������ģ�Ͳ���
SetSimulinkAutosar(module_name);    % ����ģ����ز�����MPT/CodeGeneration��)
%% ����ģ����ϸϸ��
% �����ϵͳ:Function-Call Subsystem
AddSubSyst('Function-Call Subsystem', subsyst_name, [220 100 900 1000]);

%% Add/Set ϵͳ���������Port
% ��TruthInpot/TruthOutport�������in_port_info/out_port_info
% ����в�������
InNameCol = InSize(2);
OutNameCol = OutSize(2);
InTypeCol = 4;
OutTypeCol = 4;
InDimCol = 5;
OutDimCol = 5;
% ��ԭʼ����ȡ1-3��port_info,[name type dims]
in_port_info = TruthInport(:,[InNameCol InTypeCol InDimCol]);
out_port_info = TruthOutport(:,[OutNameCol OutTypeCol OutDimCol]);

% ���SWC Module��port��Ӻ�����
AddPort(module_name, 1, in_port_info);
AddPort(module_name, 2,out_port_info);

% �ڲ�SWC��Subsystem��port��Ӻ�����
AddPort(subsyst_name, 1, in_port_info);
AddPort(subsyst_name, 2,out_port_info);
% ����������Runable
runnable_periodic = '0.01';
StepName = strcat(module_name, '/', 'Runnable_', module_name, '_Step');
add_block('simulink/Commonly Used Blocks/In1', StepName, 'Position', [350 450 450 500]);
set_param(StepName, 'SampleTime', runnable_periodic);
set_param(StepName, 'OutputFunctionCall', 'on');
fprintf("[LOG]SubSystem/Inport/Outport/RunnablePort add sucessful\n");
% ��������ӵ�ģ���������
ret = AddLine(subsyst_name);
set_param(StepName, 'Port', '1'); % ������ɺ�Ϊ�����������Runnable���ó�1,ģ������������������ɺ������ã�
% if ret == 1 % ret==1 ˵������ʱ��δ��ƥ�䵽�ӿ�
%     AutoCheckPorts();   % �Զ�����Ports���,�Ƿ��ܹ�����
% end
% ע:ģ����������⣬����������������ͨ��SimAssist�����ɣ���˽ű��в����и���
%{
for i = 1:InPortNum
    InName = input{i, NameCol};
    TypeName = input{i, TypeCol};
    NameLen = input{i, LenCol};
    add_block('simulink/Commonly Used Blocks/Data Type Conversion', strcat(subsyst_name, '/', InName, '_convert'), 'Position', [220 100 + i * PortInterval 320 115 + i * PortInterval]);
    set_param(strcat(subsyst_name, '/', InName, '_convert'), 'OutDataTypeStr', 'uint8');
    add_line(subsyst_name, strcat(InName, '/1'), strcat(InName, '_convert/1')); % ģ���ڲ�����
    add_block('simulink/Commonly Used Blocks/Terminator', strcat(subsyst_name, '/', InName, '_1'), 'Position', [380 100 + i * 50 420 115 + i * 50]); %��Ӷ�ӦTerminator
    add_line(subsyst_name, strcat(InName, '_convert/1'), strcat(InName, '_1/1')); % ģ���ڲ�����
    if PARAM_SET_AUTO == 1
        % SetInport���ͺ�Dimension

        port_num = str2double(NameLen);

        if port_num > 1
        else
            % ����Ƕ�Dimension�źţ���˲����ر��޸�
        end
    end
end

for i = 1:OutPortNum
    OutName = output{i, NameCol};
    TypeName = output{i, TypeCol};
    NameLen = output{i, LenCol};
    if PARAM_SET_AUTO == 1
        % SetOutport���ͺ�Dimension
        port_num = str2double(NameLen);
        if port_num > 1
            set_param(strcat(module_name, '/', OutName), 'PortDimensions', NameLen);
            set_param(strcat(subsyst_name, '/', OutName), 'PortDimensions', NameLen);
        else
            ConstName = strcat(subsyst_name, '/', OutName, 'Num');
            add_block('simulink/Commonly Used Blocks/Constant', ConstName, 'Position', [1700 100 + i * PortInterval 1740 115 + i * PortInterval]);
            add_block('simulink/Commonly Used Blocks/Data Type Conversion', strcat(subsyst_name, '/', OutName, '_1'), 'Position', [1830 100 + i * PortInterval 1885 115 + i * PortInterval])
            add_line(subsyst_name, strcat(OutName, 'Num/1'), strcat(OutName, '_1/1'));
            set_param(strcat(subsyst_name, '/', OutName, '_1'), 'OutDataTypeStr', TypeName);
            add_line(subsyst_name, strcat(OutName, '_1/1'), strcat(OutName, '/1'));
        end
    end
end



%% 3.���߲�����������
modelInportPos = get_param(strcat(module_name, '/', module_name), 'InputPorts'); % �����õġ�Subsystem��δ�ĳ�Ŀ����ģ������
Inport = find_system(module_name, 'SearchDepth', 1, 'BlockType', 'Inport');

for i = 1:length(Inport)
    s = get_param(Inport{i}, 'PortConnectivity');
    add_line(module_name, [s.Position(1, 1), s.Position(1, 2); modelInportPos(i, 1), modelInportPos(i, 2)]);

    if (i < length(Inport))
        set_param(Inport{i}, 'Position', [(modelInportPos(i, 1) - 100), (modelInportPos(i, 2) - 7.5), (modelInportPos(i, 1) - 70), (modelInportPos(i, 2) + 7.5)]);
    else
        set_param(Inport{i}, 'Position', [(modelInportPos(i, 1) - 250), (modelInportPos(i, 2) - 80), (modelInportPos(i, 1) - 220), (modelInportPos(i, 2) - 65)]);
    end

end

% Runaableλ�õ�������
modelOutportPos = get_param(strcat(module_name, '/', module_name), 'OutputPorts'); %
Outport = find_system(module_name, 'SearchDepth', 1, 'BlockType', 'Outport');

for i = 1:length(Outport)
    s = get_param(Outport{i}, 'PortConnectivity');
    add_line(module_name, [modelOutportPos(i, 1), modelOutportPos(i, 2); s.Position(1, 1), s.Position(1, 2)]);
    set_param(Outport{i}, 'Position', [(modelOutportPos(i, 1) + 70), (modelOutportPos(i, 2) - 7.5), (modelOutportPos(i, 1) + 100), (modelOutportPos(i, 2) + 7.5)])
end

fprintf('Log:Simulink������ɣ�ʣ�ಽ�����ֶ�����Autosar��������\n');
%}

%% New Develope Parts Autosar �����������
fprintf('Log:��ʼ����Autosar��������\n');
autosar.api.delete(module_name);    % ɾ�����ڵ�Autosar����
fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b5.�����Զ�����autosar���ã���Լ��Ҫ1~2����...');

%%
autosar.api.create(module_name,'default');   % ����Atuosar persepective 
fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b5.�����Զ�����autosar����...');
% autosar.api.create('JABS');   % �紴��ģ�ͺ�Խӿ����޸Ļ�ϣ��ɾ�������ù��Ļ������ø��������ɾ��
% Use AUTOSAR property functions
arProps = autosar.api.getAUTOSARProperties(module_name);

% ------------Runable��������------------ %
% Find AUTOSAR runnables
swc = get(arProps, 'XmlOptions', 'ComponentQualifiedName');
ib = get(arProps, swc, 'Behavior');
runnables = get(arProps, ib, 'Runnables');

% Init Runnables�޸�
runable_1 = runnables{1};
initRunnable = char(strcat('Runnable_', module_name, '_Init'));
set(arProps, runable_1, 'Name', initRunnable, 'symbol', initRunnable);
eventNmae_init = char(strcat('Event_', module_name, '_Init'));
add(arProps, ib, 'Events', eventNmae_init, 'Category', 'InitEvent', 'StartOnEvent', [ib '/' initRunnable]);

% Step Runnables�޸�
runable_2 = runnables{2};
periodicRunnable = char(strcat('Runnable_', module_name, '_Step'));
set(arProps, runable_2, 'Name', periodicRunnable, 'symbol', periodicRunnable);
eventName_step = char(strcat('Event_', module_name, '_Step'));
ifPaths = char(find(arProps, ib, 'TimingEvent'));
set(arProps, ifPaths, 'Name', eventName_step);

%
% add(arProps,ib,'Events',eventName_step,'Category','TimingEvent','Period',1,'StartOnEvent',[ib '/' periodicRunnable]);
%
% % Add AUTOSAR Events
% add(arProps,ib,'Runnables',initRunnable);
% add(arProps,ib,'Runnables',periodicRunnable);
% % Add AUTOSAR timing event
%
%
% add(arProps,ib,'Events',eventName_step,'Category','TimingEvent','Period',1,'StartOnEvent',[ib '/' periodicRunnable]);

% ------------XmlĿ¼����------------ %
% Specify AUTOSAR application data type package path for XML export
TypePackage = get(arProps, 'XmlOptions', 'DataTypePackage');
set(arProps, 'XmlOptions', 'SwBaseTypePackage', TypePackage);
set(arProps, 'XmlOptions', 'ConstantSpecificationPackage', TypePackage);
path_a1 = strcat(TypePackage, '/ApplDataTypes/DataConstrs');
set(arProps, 'XmlOptions', 'DataConstraintPackage', path_a1);
path_a2 = strcat(TypePackage, '/SystemConstants');
set(arProps, 'XmlOptions', 'SystemConstantPackage', path_a2);
path_a3 = strcat(TypePackage, '/SwAddrMethods');
set(arProps, 'XmlOptions', 'SwAddressMethodPackage', path_a3);
set(arProps, 'XmlOptions', 'CompuMethodPackage', TypePackage);
set(arProps, 'XmlOptions', 'UnitPackage', TypePackage);
fprintf('Log:Autosar������ɣ����˹���ʵ�Ƿ�������⣬ȷ�����������Կ�ʼ����[Code Generation]����\n');

% ����ExplicitReceive
% slMap=autosar.api.getSimulinkMapping(module_name);
% for i=3:in_excel_num
%     mapInport(slMap,input(i,2),input(i,2),input(i,2),'ExplicitReceive');
%     h = get_param(strcat(module_name,'/',Inport(i-2),'_1'),'PortHandles');
%     mapSignal(slMap,h.Outport(1),'StaticMemory');
% end
% for i=3:out_excel_num
%     mapOutport(slMap,output(i,2),output(i,2),output(i,2),'ExplicitSend');
%     h = get_param(strcat(module_name,'/',Outport(i-2),'_1'),'PortHandles');
%     mapSignal(slMap,h.Outport(1),'StaticMemory');
% end
% autosar.api.syncModel(module_name);


% Update Autosar
% autosar.api.syncModel(module_name);
%% 4.�������ɵ�ARXML�ļ�
load_module = 0;

if load_module ~= 0
    file_1 = char(strcat(module_name, '_component.arxml'));
    file_2 = char(strcat(module_name, '_datatype.arxml'));
    file_3 = char(strcat(module_name, '_implementation.arxml'));
    file_4 = char(strcat(module_name, '_interface.arxml'));
    arc = arxml.importer({file_1, file_2, file_3, file_4});
    path_1 = char(strcat(['/' char(module_name) '_pkg/' char(module_name) '_swc/' char(module_name)]));
    createComponentAsModel(arc, path_1, 'ModelPeriodicRunnablesAs', 'FunctionCallSubsystem');
end
