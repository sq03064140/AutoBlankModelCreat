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
A1 = strcat(TypePackage,'/ApplDataTypes/DataConstrs');
set(arProps,'XmlOptions','DataConstraintPackage',A1);
A2 = strcat(TypePackage,'/SystemConstants');
set(arProps,'XmlOptions','SystemConstantPackage',A2);
A3 = strcat(TypePackage,'/SwAddrMethods');
set(arProps,'XmlOptions','SwAddressMethodPackage',A3);
set(arProps,'XmlOptions','CompuMethodPackage',TypePackage);
set(arProps,'XmlOptions','UnitPackage',TypePackage);
fprintf('Log:Autosar�������\n');
% Update Autosar
% autosar.api.syncModel(module_name);
%% 4.�������ɵ�ARXML�ļ�
load_module = 0;
if load_module ~= 0
    arc=arxml.importer({'JABS_component.arxml','JABS_datatype.arxml','JABS_implementation.arxml','JABS_interface.arxml'})
    createComponentAsModel(arc,'/JABS_pkg/JABS_swc/JABS','ModelPeriodicRunnablesAs','FunctionCallSubsystem')
end