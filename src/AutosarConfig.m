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
A1 = strcat(TypePackage,'/ApplDataTypes/DataConstrs');
set(arProps,'XmlOptions','DataConstraintPackage',A1);
A2 = strcat(TypePackage,'/SystemConstants');
set(arProps,'XmlOptions','SystemConstantPackage',A2);
A3 = strcat(TypePackage,'/SwAddrMethods');
set(arProps,'XmlOptions','SwAddressMethodPackage',A3);
set(arProps,'XmlOptions','CompuMethodPackage',TypePackage);
set(arProps,'XmlOptions','UnitPackage',TypePackage);
fprintf('Log:Autosar配置完成\n');
% Update Autosar
% autosar.api.syncModel(module_name);
%% 4.导入生成的ARXML文件
load_module = 0;
if load_module ~= 0
    arc=arxml.importer({'JABS_component.arxml','JABS_datatype.arxml','JABS_implementation.arxml','JABS_interface.arxml'})
    createComponentAsModel(arc,'/JABS_pkg/JABS_swc/JABS','ModelPeriodicRunnablesAs','FunctionCallSubsystem')
end