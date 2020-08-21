eval('clear all');
close all;
clc;
% Coded by GaoHang / YuXiaoyang
% Soft Updata Log
% 200624:����Autosar����
% 200630:����
%on matlabR2018b 
% ��ز������� %
fprintf('ȷ��Ŀ���ļ���Ŀ¼�½���һ��excel�ļ���ͬʱ���ļ�δ����.\n');
run Rte_Type;   % Load Rte_Type to WorkSpace
addpath('MatFunc'); % �Ӻ���Ŀ¼
PARAM_SET_AUTO = 1;     % �Զ�����I/Oģ���������ͺͳ���(0�����ã������ֶ����ã�1�����excel���ɣ�
if PARAM_SET_AUTO ~= 1
    fprintf('LOG:Warning!�Զ�����I/O�ӿ������Լ��ӿڳ��ȹ��ܹر�\n');
end
%% 1.find/get excel file name,get I/O name.
getFileName = GetFileName(1); % ��ȡExcel�ļ������� mode=1 �Զ�������mode=2ͨ��matalb UIѡȡ
% [file,getFileName] = uigetfile('*.xlsx'); % UI��ʽ��ȡ
%% 2.��ȡ�������
ColRange = "A:G";
% ������ӱ����Input������,���õ���ѡ�� 
opts = spreadsheetImportOptions("NumVariables", 7);
% ָ��������ͷ�Χ 
opts.Sheet = 1; %excel �ڼ�ҳ����
opts.DataRange = ColRange; 
% ָ�������ƺ�����
opts.VariableNames = ["No", "ModuleInterface","Description","Data_type_T","Dimension","DataType","Input"];
opts.VariableTypes = ["string", "string", "string", "string", "string", "string", "string"];
opts = setvaropts(opts, [1, 2, 3, 4, 5, 6, 7], "WhitespaceRule", "preserve");
opts = setvaropts(opts, [1, 2, 3, 4, 5, 6, 7], "EmptyFieldRule", "auto");
InputPage = readtable(getFileName, opts, "UseExcel", false);    % ͬһ���ļ������·��
% �����ʱ����
clear  opts

% ������ӱ����Output������
opts = spreadsheetImportOptions("NumVariables", 7);
opts.Sheet = 2; %excel �ڼ�ҳ����
opts.DataRange = ColRange; 
opts.VariableNames = ["No", "ModuleInterface","Description","Data_type_T","Dimension","DataType","Output"];
opts.VariableTypes = ["string", "string", "string", "string", "string", "string", "string"];
opts = setvaropts(opts, [1, 2, 3, 4, 5, 6, 7], "WhitespaceRule", "preserve");
opts = setvaropts(opts, [1, 2, 3, 4, 5, 6, 7], "EmptyFieldRule", "auto");
OutputPage = readtable(getFileName, opts, "UseExcel", false);
% �����ʱ����
clear  opts

% ת��Ϊ�������
input_1 = table2array(InputPage);
output_1 = table2array(OutputPage);
%% 3.��Excel��ȡ����������ȡ���
NameCol = 2;
StartLine = 2;
fprintf("Log:[Inport] SWC inport number:");
[input,InPortNum]=GetTruthTable(input_1,StartLine,NameCol); % ��ȡ���ȥ���հ�����(In)
fprintf("Log:[Outport] SWC inport number:");
[output,OutPortNum]=GetTruthTable(output_1,StartLine,NameCol); % ��ȡ���ȥ���հ�����(Out)
module_name = GetModuleName(output,NameCol);    % ��ȡģ������
subsyst_name = strcat(module_name,'/',module_name);
%% 4.�����ļ���������Ӧ�������ɲ���
SetSimulinkAutosar(module_name);
%% 5.����ģ����ϸϸ��
% 5.1 ���ģ�͵�function-call��ϵͳ
PortInterval = 50;
block_high = max(InPortNum,OutPortNum)*PortInterval+300;
AddSubSyst(subsyst_name,block_high);
% 5.2 ���ģ��Inport&Sub-Inportģ��
TypeCol = 4;
LenCol  = 5;

for i=1:InPortNum
    InName =   input{i,NameCol};
    TypeName = input{i,TypeCol};
    NameLen =  input{i,LenCol};
    add_block('simulink/Commonly Used Blocks/In1',strcat(module_name,'/',InName),'Position',[50 100+i*PortInterval 80 115+i*PortInterval]);     % ����ӿ�
    add_block('simulink/Commonly Used Blocks/In1',strcat(subsyst_name,'/',InName),'Position',[50 100+i*PortInterval 80 115+i*PortInterval]);    % Fucntion-call Subsyst ������ӿ�
    add_block('simulink/Commonly Used Blocks/Data Type Conversion',strcat(subsyst_name,'/',InName,'_convert'),'Position',[220 100+i*PortInterval 320 115+i*PortInterval]);
    set_param(strcat(subsyst_name,'/',InName,'_convert'),'OutDataTypeStr','uint8');
    add_line(subsyst_name,strcat(InName,'/1'),strcat(InName,'_convert/1'));  % ģ���ڲ�����
    add_block('simulink/Commonly Used Blocks/Terminator',strcat(subsyst_name,'/',InName,'_1'),'Position',[380 100+i*50 420 115+i*50]);  %��Ӷ�ӦTerminator
    add_line(subsyst_name,strcat(InName,'_convert/1'),strcat(InName,'_1/1'));  % ģ���ڲ�����
    if PARAM_SET_AUTO == 1
        % SetInport���ͺ�Dimension
        set_param(strcat(module_name,'/',InName),'OutDataTypeStr',TypeName);
        set_param(strcat(subsyst_name,'/',InName),'OutDataTypeStr',TypeName);
        port_num = str2double(NameLen);
        if port_num > 1
            set_param(strcat(module_name,'/',InName),'PortDimensions',NameLen);
            set_param(strcat(subsyst_name,'/',InName),'PortDimensions',NameLen);
        else
            % ����Ƕ�Dimension�źţ���˲����ر��޸�
        end
    end
end

for i=1:OutPortNum
    OutName =  output{i,NameCol};
    TypeName = output{i,TypeCol};
    NameLen =  output{i,LenCol};
    
    add_block('simulink/Commonly Used Blocks/Out1',strcat(module_name,'/',OutName),'Position',[2050 100+i*PortInterval 2080 115+i*PortInterval]);   % �ⲿ����ӿ�
    add_block('simulink/Commonly Used Blocks/Out1',strcat(subsyst_name,'/',OutName),'Position',[2050 100+i*PortInterval 2080 115+i*PortInterval]);  % Fucntion-call Subsyst ������ӿ�
    if PARAM_SET_AUTO == 1
        % SetOutport���ͺ�Dimension
        set_param(strcat(module_name,'/',OutName),'OutDataTypeStr',TypeName);
        set_param(strcat(subsyst_name,'/',OutName),'OutDataTypeStr',TypeName);
        port_num = str2double(NameLen);
        if port_num > 1
            set_param(strcat(module_name,'/',OutName),'PortDimensions',NameLen);
            set_param(strcat(subsyst_name,'/',OutName),'PortDimensions',NameLen);
        else
            ConstName = strcat(subsyst_name,'/',OutName,'Num');
            add_block('simulink/Commonly Used Blocks/Constant',ConstName,'Position',[1700 100+i*PortInterval 1740 115+i*PortInterval]);
            add_block('simulink/Commonly Used Blocks/Data Type Conversion',strcat(subsyst_name,'/',OutName,'_1'),'Position',[1830 100+i*PortInterval 1885 115+i*PortInterval])
            add_line(subsyst_name,strcat(OutName,'Num/1'),strcat(OutName,'_1/1'));
            set_param(strcat(subsyst_name,'/',OutName,'_1'),'OutDataTypeStr',TypeName);
            add_line(subsyst_name,strcat(OutName,'_1/1'),strcat(OutName,'/1'));
        end
    end
end
% ����������Runable
StepName = strcat(module_name,'/','Runnable_',module_name,'_Step');
add_block('simulink/Commonly Used Blocks/In1',StepName,'Position',[350 450 450 500]);
set_param(StepName,'SampleTime','0.01'); %�������ڣ������ߵ��Լ���
set_param(StepName,'OutputFunctionCall','on')
fprintf("Log:I/O port,Sub-System I/O port,Runnable Input,���߶��������������\n");

%% 3.���߲�����������
modelInportPos = get_param(strcat(module_name,'/',module_name),'InputPorts'); % �����õġ�Subsystem��δ�ĳ�Ŀ����ģ������
Inport = find_system(module_name,'SearchDepth',1,'BlockType','Inport');
for i=1:length(Inport)
    s = get_param(Inport{i},'PortConnectivity');
    add_line(module_name,[s.Position(1,1),s.Position(1,2);modelInportPos(i,1),modelInportPos(i,2)]);
    if(i<length(Inport))
        set_param(Inport{i},'Position',[(modelInportPos(i,1)-100),(modelInportPos(i,2)-7.5),(modelInportPos(i,1)-70),(modelInportPos(i,2)+7.5)]);
    else
        set_param(Inport{i},'Position',[(modelInportPos(i,1)-250),(modelInportPos(i,2)-80),(modelInportPos(i,1)-220),(modelInportPos(i,2)-65)]);
    end
end
% Runaableλ�õ�������
modelOutportPos = get_param(strcat(module_name,'/',module_name),'OutputPorts'); % 
Outport = find_system(module_name,'SearchDepth',1,'BlockType','Outport');
for i=1:length(Outport)
    s = get_param(Outport{i},'PortConnectivity');
    add_line(module_name,[	modelOutportPos(i,1),modelOutportPos(i,2);s.Position(1,1),s.Position(1,2)]);
    set_param(Outport{i},'Position',[(modelOutportPos(i,1)+70),(modelOutportPos(i,2)-7.5),(modelOutportPos(i,1)+100),(modelOutportPos(i,2)+7.5)])
end
fprintf('Log:Simulink������ɣ�ʣ�ಽ�����ֶ�����Autosar��������\n');
set_param(StepName,'Port','1'); % ������ɺ�Ϊ�����������Runnable���ó�1

%% New Develope Parts
fprintf('Log:��ʼ����Autosar��������\n');
% �¿����Ĺ��ܣ������Խ׶Σ��޷�ȷ�����н�����Ƿ��ȶ�
autosar.api.create(module_name,'default');   % ����Atuosar persepective 
% autosar.api.create('JABS');   % �紴��ģ�ͺ�Խӿ����޸Ļ�ϣ��ɾ�������ù��Ļ������ø��������ɾ��
% Use AUTOSAR property functions
arProps = autosar.api.getAUTOSARProperties(module_name);

% ------------Runable��������------------ %
% Find AUTOSAR runnables
swc = get(arProps,'XmlOptions','ComponentQualifiedName');
ib =  get(arProps,swc,'Behavior');
runnables = get(arProps,ib,'Runnables');

% Init Runnables�޸�
runable_1 = runnables{1};
initRunnable = char(strcat('Runnable_',module_name,'_Init'));
set(arProps,runable_1,'Name',initRunnable,'symbol',initRunnable);
eventNmae_init = char(strcat('Event_',module_name,'_Init'));
add(arProps,ib,'Events',eventNmae_init,'Category','InitEvent','StartOnEvent',[ib '/' initRunnable]);

% Step Runnables�޸�
runable_2 = runnables{2};
periodicRunnable = char(strcat('Runnable_',module_name,'_Step'));
set(arProps,runable_2,'Name',periodicRunnable,'symbol',periodicRunnable);
eventName_step = char(strcat('Event_',module_name,'_Step'));
ifPaths=char(find(arProps,ib,'TimingEvent'));
set(arProps,ifPaths,'Name',eventName_step);

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
TypePackage = get(arProps,'XmlOptions','DataTypePackage');
set(arProps,'XmlOptions','SwBaseTypePackage',TypePackage);
set(arProps,'XmlOptions','ConstantSpecificationPackage',TypePackage);
path_a1 = strcat(TypePackage,'/ApplDataTypes/DataConstrs');
set(arProps,'XmlOptions','DataConstraintPackage',path_a1);
path_a2 = strcat(TypePackage,'/SystemConstants');
set(arProps,'XmlOptions','SystemConstantPackage',path_a2);
path_a3 = strcat(TypePackage,'/SwAddrMethods');
set(arProps,'XmlOptions','SwAddressMethodPackage',path_a3);
set(arProps,'XmlOptions','CompuMethodPackage',TypePackage);
set(arProps,'XmlOptions','UnitPackage',TypePackage);
fprintf('Log:Autosar������ɣ����˹���ʵ�Ƿ�������⣬ȷ�����������Կ�ʼ����[Code Generation]����\n');
% Update Autosar
% autosar.api.syncModel(module_name);
%% 4.�������ɵ�ARXML�ļ�
load_module = 0;
if load_module ~= 0
    file_1 = char(strcat(module_name,'_component.arxml'));
    file_2 = char(strcat(module_name,'_datatype.arxml'));
    file_3 = char(strcat(module_name,'_implementation.arxml'));
    file_4 = char(strcat(module_name,'_interface.arxml'));
    arc=arxml.importer({file_1,file_2,file_3,file_4});
    path_1 = char(strcat(['/' char(module_name) '_pkg/' char(module_name) '_swc/' char(module_name)]));
    createComponentAsModel(arc,path_1,'ModelPeriodicRunnablesAs','FunctionCallSubsystem');
end