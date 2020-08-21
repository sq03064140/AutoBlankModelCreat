% Coded by GaoHang / YuXiaoyang
% Soft Updata Log
% 200624:更新Autosar设置
% 200630:重写了所需调用的函数
% on matlab R2018b
% 相关参数配置
% ----------------------------------------%

%% 清理Matlab缓存和文件，添加函数目录
eval('clear all');
close all;
clc;
addpath('D:\BaiduNetdiskDownload\MatlabWorkSpace\Project\lib'); % 工具函数目录
run Rte_Type; % Load Rte_Type to WorkSpace

PARAM_SET_AUTO = 1; % 自动设置I/O模块数据类型和长度(0则不设置，后期手动配置，1则根据excel生成）
if PARAM_SET_AUTO ~= 1
    fprintf('[WARNING]:Warning!自动配置I/O接口类型以及接口长度功能关闭\n');
end

%% Find/get excel file name,get I/O接口说明书.
SearchCondi = '*.xls*';
FilePath = GetFileName(0,SearchCondi); % 读取Excel文件夹名称 mode=1 自动检索，mode=2通过matalb UI选取

%% 读取表格内容
InColRange = "A:G";
OutColRange = "A:G";
InSize = [2, 2];    % 输入表格中接口名称起始位置
OutSize= [2, 2];    % 输出表格中接口名称起始位置

% 读取Inport和Outport的Excel名称
InputTable = ReadIO(FilePath,1,InColRange);
OutputTable = ReadIO(FilePath,2,OutColRange);   % 读取完整表格
[TruthInport,   InPortNum] = GetTruthTable( InputTable, InSize);
[TruthOutport, OutPortNum] = GetTruthTable(OutputTable,OutSize);
fprintf("[LOG] Inport Numbers:\t%d\n", InPortNum);
fprintf("[LOG]Outport Numbers:\t%d\n",OutPortNum);

% 根据Inport/Outport获取所需建的SWC的名
module_name = GetModuleName(TruthOutport, OutSize(2)); % 读取模块名称
subsyst_name = strcat(module_name, '/', module_name);
fprintf('[LOG]SWC full path:\t %s \n', subsyst_name);

%% 建立Simulink模型文件
% 流程:创建文件->设置Simulink属性->添加子系统->添加各Port(I/O)
% 检测是否已打开同名文件，如已经打开同名文件
% 例如:JABS/JABS已经打开，则另存为JABS/JABS_AutoSve_Data
try
    warning('off');     % 关闭warning后，将已打开的模型另存为
    newfile = strcat(module_name, '_AutoSave_', datestr(now, 'yyyymmdd_HHMM'));
    close_system(module_name, newfile);
    fprintf('[LOG]您已打开的模型[%s.slx ]文件另存为[%s.slx ]\n', module_name, newfile);
    warning('on');
catch
end
% 创建模型&打开模型
new_system(module_name);
open_system(module_name);           % 创建相关模型并打开
SetSimulinkAutosar(module_name);    % 设置模型相关参数（MPT/CodeGeneration等)
%% 配置模型详细细节
% 添加子系统:Function-Call Subsystem
AddSubSyst('Function-Call Subsystem', subsyst_name, [220 100 900 1000]);

%% Add/Set 系统中所需各类Port
% 由TruthInpot/TruthOutport处理后获得in_port_info/out_port_info
% 表格中参数设置
InNameCol = InSize(2);
OutNameCol = OutSize(2);
InTypeCol = 4;
OutTypeCol = 4;
InDimCol = 5;
OutDimCol = 5;
% 由原始表格获取1-3行port_info,[name type dims]
in_port_info = TruthInport(:,[InNameCol InTypeCol InDimCol]);
out_port_info = TruthOutport(:,[OutNameCol OutTypeCol OutDimCol]);

% 外层SWC Module的port添加和设置
AddPort(module_name, 1, in_port_info);
AddPort(module_name, 2,out_port_info);

% 内层SWC的Subsystem各port添加和设置
AddPort(subsyst_name, 1, in_port_info);
AddPort(subsyst_name, 2,out_port_info);
% 创建并配置Runable
runnable_periodic = '0.01';
StepName = strcat(module_name, '/', 'Runnable_', module_name, '_Step');
add_block('simulink/Commonly Used Blocks/In1', StepName, 'Position', [350 450 450 500]);
set_param(StepName, 'SampleTime', runnable_periodic);
set_param(StepName, 'OutputFunctionCall', 'on');
fprintf("[LOG]SubSystem/Inport/Outport/RunnablePort add sucessful\n");
% 根据已添加的模块进行连线
ret = AddLine(subsyst_name);
set_param(StepName, 'Port', '1'); % 规整完成后，为方便后续，将Runnable设置成1,模块规整放在最后（连线完成后再设置）
% if ret == 1 % ret==1 说明连线时有未被匹配到接口
%     AutoCheckPorts();   % 自动进行Ports检测,是否能够对上
% end
% 注:模块的美观问题，例如规整等问题可以通过SimAssist插件完成，因此脚本中不进行更新
%{
for i = 1:InPortNum
    InName = input{i, NameCol};
    TypeName = input{i, TypeCol};
    NameLen = input{i, LenCol};
    add_block('simulink/Commonly Used Blocks/Data Type Conversion', strcat(subsyst_name, '/', InName, '_convert'), 'Position', [220 100 + i * PortInterval 320 115 + i * PortInterval]);
    set_param(strcat(subsyst_name, '/', InName, '_convert'), 'OutDataTypeStr', 'uint8');
    add_line(subsyst_name, strcat(InName, '/1'), strcat(InName, '_convert/1')); % 模块内部连线
    add_block('simulink/Commonly Used Blocks/Terminator', strcat(subsyst_name, '/', InName, '_1'), 'Position', [380 100 + i * 50 420 115 + i * 50]); %添加对应Terminator
    add_line(subsyst_name, strcat(InName, '_convert/1'), strcat(InName, '_1/1')); % 模块内部连线
    if PARAM_SET_AUTO == 1
        % SetInport类型和Dimension

        port_num = str2double(NameLen);

        if port_num > 1
        else
            % 输入非多Dimension信号，因此不用特别修改
        end
    end
end

for i = 1:OutPortNum
    OutName = output{i, NameCol};
    TypeName = output{i, TypeCol};
    NameLen = output{i, LenCol};
    if PARAM_SET_AUTO == 1
        % SetOutport类型和Dimension
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



%% 3.连线并规整好连线
modelInportPos = get_param(strcat(module_name, '/', module_name), 'InputPorts'); % 这里用的‘Subsystem’未改成目标子模块名称
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

% Runaable位置单独设置
modelOutportPos = get_param(strcat(module_name, '/', module_name), 'OutputPorts'); %
Outport = find_system(module_name, 'SearchDepth', 1, 'BlockType', 'Outport');

for i = 1:length(Outport)
    s = get_param(Outport{i}, 'PortConnectivity');
    add_line(module_name, [modelOutportPos(i, 1), modelOutportPos(i, 2); s.Position(1, 1), s.Position(1, 2)]);
    set_param(Outport{i}, 'Position', [(modelOutportPos(i, 1) + 70), (modelOutportPos(i, 2) - 7.5), (modelOutportPos(i, 1) + 100), (modelOutportPos(i, 2) + 7.5)])
end

fprintf('Log:Simulink设置完成，剩余步骤需手动设置Autosar参数即可\n');
%}

%% New Develope Parts Autosar 相关内容设置
fprintf('Log:开始配置Autosar部分内容\n');
autosar.api.delete(module_name);    % 删除现在的Autosar配置
fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b5.正在自动生成autosar配置，大约需要1~2分钟...');

%%
autosar.api.create(module_name,'default');   % 创建Atuosar persepective 
fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b5.正在自动调整autosar配置...');
% autosar.api.create('JABS');   % 如创建模型后对接口有修改或希望删除已配置过的环境可用该命令进行删除
% Use AUTOSAR property functions
arProps = autosar.api.getAUTOSARProperties(module_name);

% ------------Runable部分配置------------ %
% Find AUTOSAR runnables
swc = get(arProps, 'XmlOptions', 'ComponentQualifiedName');
ib = get(arProps, swc, 'Behavior');
runnables = get(arProps, ib, 'Runnables');

% Init Runnables修改
runable_1 = runnables{1};
initRunnable = char(strcat('Runnable_', module_name, '_Init'));
set(arProps, runable_1, 'Name', initRunnable, 'symbol', initRunnable);
eventNmae_init = char(strcat('Event_', module_name, '_Init'));
add(arProps, ib, 'Events', eventNmae_init, 'Category', 'InitEvent', 'StartOnEvent', [ib '/' initRunnable]);

% Step Runnables修改
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

% ------------Xml目录配置------------ %
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
fprintf('Log:Autosar配置完成，请人工核实是否存在问题，确定无问题后可以开始进行[Code Generation]步骤\n');

% 设置ExplicitReceive
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
%% 4.导入生成的ARXML文件
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
