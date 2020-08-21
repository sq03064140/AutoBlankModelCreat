eval('clear all');
close all;
clc;
% Coded by GaoHang / YuXiaoyang
% Soft Updata Log
% 200624:更新Autosar设置
% 200630:整合
%on matlabR2018b 
% 相关参数配置 %
fprintf('确认目标文件夹目录下仅有一个excel文件，同时该文件未被打开.\n');
run Rte_Type;   % Load Rte_Type to WorkSpace
addpath('MatFunc'); % 子函数目录
PARAM_SET_AUTO = 1;     % 自动设置I/O模块数据类型和长度(0则不设置，后期手动配置，1则根据excel生成）
if PARAM_SET_AUTO ~= 1
    fprintf('LOG:Warning!自动配置I/O接口类型以及接口长度功能关闭\n');
end
%% 1.find/get excel file name,get I/O name.
getFileName = GetFileName(1); % 读取Excel文件夹名称 mode=1 自动检索，mode=2通过matalb UI选取
% [file,getFileName] = uigetfile('*.xlsx'); % UI方式获取
%% 2.读取表格内容
ColRange = "A:G";
% 导入电子表格中Input的数据,设置导入选项 
opts = spreadsheetImportOptions("NumVariables", 7);
% 指定工作表和范围 
opts.Sheet = 1; %excel 第几页名称
opts.DataRange = ColRange; 
% 指定列名称和类型
opts.VariableNames = ["No", "ModuleInterface","Description","Data_type_T","Dimension","DataType","Input"];
opts.VariableTypes = ["string", "string", "string", "string", "string", "string", "string"];
opts = setvaropts(opts, [1, 2, 3, 4, 5, 6, 7], "WhitespaceRule", "preserve");
opts = setvaropts(opts, [1, 2, 3, 4, 5, 6, 7], "EmptyFieldRule", "auto");
InputPage = readtable(getFileName, opts, "UseExcel", false);    % 同一个文件夹相对路径
% 清除临时变量
clear  opts

% 导入电子表格中Output的数据
opts = spreadsheetImportOptions("NumVariables", 7);
opts.Sheet = 2; %excel 第几页名称
opts.DataRange = ColRange; 
opts.VariableNames = ["No", "ModuleInterface","Description","Data_type_T","Dimension","DataType","Output"];
opts.VariableTypes = ["string", "string", "string", "string", "string", "string", "string"];
opts = setvaropts(opts, [1, 2, 3, 4, 5, 6, 7], "WhitespaceRule", "preserve");
opts = setvaropts(opts, [1, 2, 3, 4, 5, 6, 7], "EmptyFieldRule", "auto");
OutputPage = readtable(getFileName, opts, "UseExcel", false);
% 清除临时变量
clear  opts

% 转换为输出类型
input_1 = table2array(InputPage);
output_1 = table2array(OutputPage);
%% 3.对Excel读取结果，处理读取结果
NameCol = 2;
StartLine = 2;
fprintf("Log:[Inport] SWC inport number:");
[input,InPortNum]=GetTruthTable(input_1,StartLine,NameCol); % 读取表格去除空白内容(In)
fprintf("Log:[Outport] SWC inport number:");
[output,OutPortNum]=GetTruthTable(output_1,StartLine,NameCol); % 读取表格去除空白内容(Out)
module_name = GetModuleName(output,NameCol);    % 读取模块名称
subsyst_name = strcat(module_name,'/',module_name);
%% 4.建立文件，配置相应代码生成参数
SetSimulinkAutosar(module_name);
%% 5.配置模型详细细节
% 5.1 添加模型的function-call子系统
PortInterval = 50;
block_high = max(InPortNum,OutPortNum)*PortInterval+300;
AddSubSyst(subsyst_name,block_high);
% 5.2 添加模块Inport&Sub-Inport模块
TypeCol = 4;
LenCol  = 5;

for i=1:InPortNum
    InName =   input{i,NameCol};
    TypeName = input{i,TypeCol};
    NameLen =  input{i,LenCol};
    add_block('simulink/Commonly Used Blocks/In1',strcat(module_name,'/',InName),'Position',[50 100+i*PortInterval 80 115+i*PortInterval]);     % 输入接口
    add_block('simulink/Commonly Used Blocks/In1',strcat(subsyst_name,'/',InName),'Position',[50 100+i*PortInterval 80 115+i*PortInterval]);    % Fucntion-call Subsyst 的输入接口
    add_block('simulink/Commonly Used Blocks/Data Type Conversion',strcat(subsyst_name,'/',InName,'_convert'),'Position',[220 100+i*PortInterval 320 115+i*PortInterval]);
    set_param(strcat(subsyst_name,'/',InName,'_convert'),'OutDataTypeStr','uint8');
    add_line(subsyst_name,strcat(InName,'/1'),strcat(InName,'_convert/1'));  % 模块内部连线
    add_block('simulink/Commonly Used Blocks/Terminator',strcat(subsyst_name,'/',InName,'_1'),'Position',[380 100+i*50 420 115+i*50]);  %添加对应Terminator
    add_line(subsyst_name,strcat(InName,'_convert/1'),strcat(InName,'_1/1'));  % 模块内部连线
    if PARAM_SET_AUTO == 1
        % SetInport类型和Dimension
        set_param(strcat(module_name,'/',InName),'OutDataTypeStr',TypeName);
        set_param(strcat(subsyst_name,'/',InName),'OutDataTypeStr',TypeName);
        port_num = str2double(NameLen);
        if port_num > 1
            set_param(strcat(module_name,'/',InName),'PortDimensions',NameLen);
            set_param(strcat(subsyst_name,'/',InName),'PortDimensions',NameLen);
        else
            % 输入非多Dimension信号，因此不用特别修改
        end
    end
end

for i=1:OutPortNum
    OutName =  output{i,NameCol};
    TypeName = output{i,TypeCol};
    NameLen =  output{i,LenCol};
    
    add_block('simulink/Commonly Used Blocks/Out1',strcat(module_name,'/',OutName),'Position',[2050 100+i*PortInterval 2080 115+i*PortInterval]);   % 外部输出接口
    add_block('simulink/Commonly Used Blocks/Out1',strcat(subsyst_name,'/',OutName),'Position',[2050 100+i*PortInterval 2080 115+i*PortInterval]);  % Fucntion-call Subsyst 的输出接口
    if PARAM_SET_AUTO == 1
        % SetOutport类型和Dimension
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
% 创建并配置Runable
StepName = strcat(module_name,'/','Runnable_',module_name,'_Step');
add_block('simulink/Commonly Used Blocks/In1',StepName,'Position',[350 450 450 500]);
set_param(StepName,'SampleTime','0.01'); %设置周期，但连线得自己来
set_param(StepName,'OutputFunctionCall','on')
fprintf("Log:I/O port,Sub-System I/O port,Runnable Input,三者都创建并设置完成\n");

%% 3.连线并规整好连线
modelInportPos = get_param(strcat(module_name,'/',module_name),'InputPorts'); % 这里用的‘Subsystem’未改成目标子模块名称
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
% Runaable位置单独设置
modelOutportPos = get_param(strcat(module_name,'/',module_name),'OutputPorts'); % 
Outport = find_system(module_name,'SearchDepth',1,'BlockType','Outport');
for i=1:length(Outport)
    s = get_param(Outport{i},'PortConnectivity');
    add_line(module_name,[	modelOutportPos(i,1),modelOutportPos(i,2);s.Position(1,1),s.Position(1,2)]);
    set_param(Outport{i},'Position',[(modelOutportPos(i,1)+70),(modelOutportPos(i,2)-7.5),(modelOutportPos(i,1)+100),(modelOutportPos(i,2)+7.5)])
end
fprintf('Log:Simulink设置完成，剩余步骤需手动设置Autosar参数即可\n');
set_param(StepName,'Port','1'); % 规整完成后，为方便后续，将Runnable设置成1

%% New Develope Parts
fprintf('Log:开始配置Autosar部分内容\n');
% 新开发的功能，属测试阶段，无法确保运行结果和是否稳定
autosar.api.create(module_name,'default');   % 创建Atuosar persepective 
% autosar.api.create('JABS');   % 如创建模型后对接口有修改或希望删除已配置过的环境可用该命令进行删除
% Use AUTOSAR property functions
arProps = autosar.api.getAUTOSARProperties(module_name);

% ------------Runable部分配置------------ %
% Find AUTOSAR runnables
swc = get(arProps,'XmlOptions','ComponentQualifiedName');
ib =  get(arProps,swc,'Behavior');
runnables = get(arProps,ib,'Runnables');

% Init Runnables修改
runable_1 = runnables{1};
initRunnable = char(strcat('Runnable_',module_name,'_Init'));
set(arProps,runable_1,'Name',initRunnable,'symbol',initRunnable);
eventNmae_init = char(strcat('Event_',module_name,'_Init'));
add(arProps,ib,'Events',eventNmae_init,'Category','InitEvent','StartOnEvent',[ib '/' initRunnable]);

% Step Runnables修改
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

% ------------Xml目录配置------------ %
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
fprintf('Log:Autosar配置完成，请人工核实是否存在问题，确定无问题后可以开始进行[Code Generation]步骤\n');
% Update Autosar
% autosar.api.syncModel(module_name);
%% 4.导入生成的ARXML文件
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