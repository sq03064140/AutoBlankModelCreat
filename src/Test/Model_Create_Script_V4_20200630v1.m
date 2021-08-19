eval('clear all');
%% 1.����Excel�ĵ�������������ź�
fprintf('ȷ��Ŀ���ļ���Ŀ¼�½���һ��excel�ļ���ͬʱ���ļ�δ����.\n');
getFileName=ls(strcat(pwd,'\*.xlsx*')); %  *�ű���excel�����ļ�����ͬһ���ļ��и��ļ���������ֻ��һ���ļ�xlsx�ļ�
FileNum = size(getFileName);
if  isequal(getFileName,'') % ��ֹѡ����ļ���
    fprintf('no excel file in the path you selected\n');
elseif  FileNum ~= 1
    fprintf('Exist more than 1 *.xlsx in this path\n');
else
    fprintf('Your Target .xlsx file is: [%s ]\n',getFileName);
end
%% ������ӱ����Input������,���õ���ѡ�� 
opts = spreadsheetImportOptions("NumVariables", 6);
opts.Sheet = 1; %excel �ڼ�ҳ����
opts.DataRange = "A:F"; 
opts.VariableNames = ["No", "ModuleInterface","I_O","Description","Data_type","PortDimensions"];	% ָ�������ƺ�����
opts.VariableTypes = ["string", "string", "string", "string", "string", "string"];
opts = setvaropts(opts, [1, 2, 3, 4, 5, 6], "WhitespaceRule", "preserve");
opts = setvaropts(opts, [1, 2, 3, 4, 5, 6], "EmptyFieldRule", "auto");
jainputoutput = readtable(getFileName, opts, "UseExcel", false);    % ͬһ���ļ������·�� % ��������
input = table2array(jainputoutput); % ת��Ϊ�������
clear  opts;    % �����ʱ����
%% ������ӱ����Output������
opts = spreadsheetImportOptions("NumVariables", 6);
opts.Sheet = 2;
opts.DataRange = "A:F"; % ����ʵ������޸�����
opts.VariableNames = ["No", "ModuleInterface","I_O","Description","Data_type","PortDimensions"];
opts.VariableTypes = ["string", "string", "string", "string", "string", "string"];
opts = setvaropts(opts, [1, 2, 3, 4, 5, 6], "WhitespaceRule", "preserve");
opts = setvaropts(opts, [1, 2, 3, 4, 5, 6], "EmptyFieldRule", "auto");
jainputoutputS1 = readtable(getFileName, opts, "UseExcel", false);
output = table2array(jainputoutputS1); % ת��Ϊ�������
clear  opts;    % �����ʱ����
in_excel_num = length(input);
out_excel_num = size(output);
out_excel_num = out_excel_num(1);
inport_num = 0;
outport_num = 0;
for i=3:in_excel_num
    if ~isequal(input(i,2),'')
        inport_num = inport_num+1;
    end
end
for i=3:out_excel_num
    if ~isequal(output(i,2),'')
        outport_num = outport_num+1;
    end
end
%% ����ģ�ͣ����ò���
%% �ļ�/ģ������,���������������ļ�
name_1 = input{2,2};
module_name = string(name_1(1:4));
warning('off')
try
    newfile = strcat(module_name,'_AutoSave_',datestr(now,'yyyymmdd_HHMM'));
    close_system(module_name,newfile);
    fprintf('���Ѿ��򿪵�ģ��[%s.slx ]�ļ��Ѿ����Ϊ[%s.slx ]\n',module_name,newfile);
catch
end
new_system(module_name); % ��������������� I/O�ӿ�
open_system(module_name);

%% ����Simulinkģ�����ò���
cs = getActiveConfigSet(module_name);
set_param(cs,'SolverType','Fixed-step');    % Solver����
stf = 'autosar.tlc';
switchTarget(cs,stf,[]);    % ����ģ���ļ�������
set_param(cs,'DefaultUnderspecifiedDataType','single');
set_param(cs,'GenerateCodeMetricsReport','on');
set_param(cs,'BlockReduction','off');
set_param(cs,'AutosarSchemaVersion','4.2');
set_param(cs,'AutosarMaxShortNameLength',32);
set_param(cs,'GenerateASAP2','on');
set_param(cs,'NoFixptDivByZeroProtection','on');
set_param(cs,'BlockReduction','on');
set_param(cs,'EfficientFloat2IntCast','on');
set_param(cs,'InlineInvariantSignals','on');
set_param(cs,'CombineSignalStateStructs','on');
set_param(cs,'UseSpecifiedMinMax','on');
set_param(cs,'UseFloatMulNetSlope','on');
set_param(cs,'BuildConfiguration','Faster Runs');
set_param(cs,'OptimizationCustomize','on');
set_param(cs,'GlobalVariableUsage','None');
set_param(cs,'ProdLongLongMode','on');
set_param(cs,'UtilityFuncGeneration','Shared location');
set_param(cs,'StateflowObjectComments','on'); 
set_param(cs,'ReqsInCode','on');
set_param(cs,'MATLABFcnDesc','on');
set_param(cs,'MATLABSourceComments','on');
set_param(cs,'LifeSpan','inf');
set_param(cs,'IntegerOverflowMsg','error');
set_param(cs,'IntegerSaturationMsg','error');
set_param(cs,'ReadBeforeWriteMsg','DisableAll');
set_param(cs,'WriteAfterReadMsg','DisableAll');
set_param(cs,'WriteAfterWriteMsg','DisableAll');
set_param(cs,'NonBusSignalsTreatedAsBus','error');
set_param(cs,'SFInvalidInputDataAccessInChartInitDiag','error');
set_param(cs,'SFTransitionOutsideNaturalParentDiag','error');
set_param(cs,'SFUnreachableExecutionPathDiag','error');
set_param(cs,'SFUndirectedBroadcastEventsDiag','error');
set_param(cs,'AssertControl','DisableAll');
set_param(cs,'EnableCustomComments','on');
set_param(cs,'ParenthesesLevel','Maximum');
set_param(cs,'UseDivisionForNetSlopeComputation','on');
set_param(cs,'EnableSignedLeftShifts','off');
set_param(cs,'EnableSignedRightShifts','off');
set_param(cs,'CastingMode','Standards');
set_param(cs,'GenerateSharedConstants','off');
set_param(cs,'SignalInfNanChecking','none');
set_param(cs,'CompileTimeRecursionLimit',0);
set_param(cs,'EnableRuntimeRecursion','off');
set_param(cs,'Solver','FixedStepDiscrete');
set_param(cs,'MultiTaskDSMMsg','error');
set_param(cs,'SignalInfNanChecking','error');
set_param(cs,'UniqueDataStoreMsg','error');
set_param(cs,'UseDivisionForNetSlopeComputation','on');
set_param(cs,'UseDivisionForNetSlopeComputation','on');
set_param(cs,'UseDivisionForNetSlopeComputation','on');
set_param(cs,'SFSimEcho','off');
set_param(cs,'UpdateModelReferenceTargets','IfOutOfDate');
set_param(cs,'ObjectivePriorities','Execution efficiency, ROM efficiency, RAM efficiency, Traceability, Safety precaution, Debugging, MISRA C:2012 guidelines, Polyspace');
set_param(cs,'ObjectivePriorities', {'Execution efficiency','ROM efficiency','RAM efficiency','Traceability','Safety precaution','Debugging','MISRA C:2012 guidelines','Polyspace'});
fprintf("1.Code generation�����������\n");

%% 2.���function-call subsystem
% Step.1 add function-call subsystemͬʱ���þ������
block_high = max(inport_num,outport_num)*35+50;
SubSystName = strcat(module_name,'/',module_name);
add_block('simulink/Ports & Subsystems/Function-Call Subsystem',SubSystName,'Position',[250 100 1850 block_high]);
% ����bussyst ��Ԫ��
delete_block(strcat(SubSystName,'/Out1'));  
delete_block(strcat(SubSystName,'/In1'));   % ɾ��I/O port
l1=find_system(SubSystName,'FindAll','on','type','line');   % �ҵ���ģ�������ߵ�handle
delete_line(l1);  % ɾ����Ӧ�߶�
set_param(strcat(SubSystName,'/function'),'SampleTimeType','periodic','SampleTime','-1');   %����function����
fprintf("2.Function Call SubSyst �������\n");

%% 2.��Ӵ�ģ��Inport/Outport
for i=3:in_excel_num
%      add_block('simulink/Commonly Used
%      Blocks/In1',strcat('JABS/','in_1'),"OutDataTypeStr","double",'Position',[50
%      150 80 115+50])   % OutDataTypeStr","double" ����ֱ�������������͡�ά�ȵ�
    if ~isequal(input(i,2),'')
        add_block('simulink/Commonly Used Blocks/In1',strcat(module_name,'/',input{i,2}),'Position',[50 100+i*35 80 115+i*35]);     % ������ӿ�
        add_block('simulink/Commonly Used Blocks/In1',strcat(SubSystName,'/',input{i,2}),'Position',[50 100+i*35 80 115+i*35]);     % Fucntion-call Subsyst ������ӿ�
%        add_block('simulink/Commonly Used Blocks/Data Type Conversion',strcat(SubSystName,'/',strcat(input{i,2},'_1')),'Position',[250 100+i*35 280 115+i*35]);
        namep = input{i,2};
        namep;
        if namep(8:8) == 'd'
            set_param(add_block('simulink/Commonly Used Blocks/Data Type Conversion',strcat(SubSystName,'/',strcat(input{i,2},'_1')),'Position',[250 100+i*35 280 115+i*35]),'OutDataTypeStr','uint16')
        elseif namep(8:8) == 'g'
            set_param(add_block('simulink/Commonly Used Blocks/Data Type Conversion',strcat(SubSystName,'/',strcat(input{i,2},'_1')),'Position',[250 100+i*35 280 115+i*35]),'OutDataTypeStr','single')
        elseif namep(8:8) == 'y'
            set_param(add_block('simulink/Commonly Used Blocks/Data Type Conversion',strcat(SubSystName,'/',strcat(input{i,2},'_1')),'Position',[250 100+i*35 280 115+i*35]),'OutDataTypeStr','uint8')
        else
            set_param(add_block('simulink/Commonly Used Blocks/Data Type Conversion',strcat(SubSystName,'/',strcat(input{i,2},'_1')),'Position',[250 100+i*35 280 115+i*35]),'OutDataTypeStr','uint16')
        end
        add_block('simulink/Commonly Used Blocks/Terminator',strcat(SubSystName,'/',strcat(input{i,2},'_2')),'Position',[450 100+i*35 465 115+i*35])
    end
end
for i=3:out_excel_num
    if ~isequal(output(i,2),'')
        add_block('simulink/Commonly Used Blocks/Out1',strcat(module_name,'/',output{i,2}),'Position',[2050 100+i*35 2080 115+i*35]);

        add_block('simulink/Commonly Used Blocks/Out1',strcat(SubSystName,'/',output{i,2}),'Position',[2050 100+i*35 2080 115+i*35]);     % Fucntion-call Subsyst ������ӿ�
%        add_block('simulink/Commonly Used Blocks/Data Type Conversion',strcat(SubSystName,'/',strcat(output{i,2},'_1')),'Position',[1850 100+i*35 1880 115+i*35]);
        namep = output{i,2};
        namep;
        if namep(8:8) == 'd'
            set_param(add_block('simulink/Commonly Used Blocks/Data Type Conversion',strcat(SubSystName,'/',strcat(output{i,2},'_1')),'Position',[1850 100+i*35 1880 115+i*35]),'OutDataTypeStr','UInt16')
        elseif namep(8:8) == 'g'
            set_param(add_block('simulink/Commonly Used Blocks/Data Type Conversion',strcat(SubSystName,'/',strcat(output{i,2},'_1')),'Position',[1850 100+i*35 1880 115+i*35]),'OutDataTypeStr','T_M_Nm_Float32')
        elseif namep(8:8) == 'y'
            set_param(add_block('simulink/Commonly Used Blocks/Data Type Conversion',strcat(SubSystName,'/',strcat(output{i,2},'_1')),'Position',[1850 100+i*35 1880 115+i*35]),'OutDataTypeStr','UInt8')
        else
            set_param(add_block('simulink/Commonly Used Blocks/Data Type Conversion',strcat(SubSystName,'/',strcat(output{i,2},'_1')),'Position',[1850 100+i*35 1880 115+i*35]),'OutDataTypeStr','UInt16')
        end
        add_block('simulink/Commonly Used Blocks/Ground',strcat(SubSystName,'/',strcat(output{i,2},'_2')),'Position',[1650 100+i*35 1665 115+i*35])
    end
end
% ����������Runable
StepName = strcat(module_name,'/','Runnable_',module_name,'_Step');
add_block('simulink/Commonly Used Blocks/In1',StepName,'Position',[350 450 450 500]);
set_param(StepName,'SampleTime','0.01'); %�������ڣ������ߵ��Լ���
set_param(StepName,'OutputFunctionCall','on');

fid = fopen('Rte_Type.m','r');
InitFcn = fscanf(fid,'%c');
fclose(fid);
set_param(module_name,'InitFcn',InitFcn);
StopFcn1 = strjoin(regexpi(InitFcn,'(?<=Simulink.NumericType;\n)(.*?)(?=.Description)','match'));
StopFcn2 = strjoin(regexpi(InitFcn,'(?<=Simulink.AliasType;\n)(.*?)(?=.Description)','match'));
StopFcn = string(strcat({'clear  '},StopFcn1,{' '},StopFcn2));
set_param(module_name,'StopFcn',StopFcn);
fprintf("3.I/O port,Sub-System I/O port,Runnable Input,���߶��������������\n");

%% 3.���߲�����������
modelInportPos = get_param(strcat(module_name,'/',module_name),'InputPorts'); % �����õġ�Subsystem��δ�ĳ�Ŀ����ģ������
Inport = find_system(module_name,'SearchDepth',1,'BlockType','Inport');
Rte_Type
for i=1:length(Inport)
    s = get_param(Inport{i},'PortConnectivity');
    h = get_param(Inport{i},'PortHandles');
    h1 = get_param(strcat(module_name,'/',module_name),'PortHandles');
    if(i<length(Inport))
        add_line(module_name,h.Outport(1),h1.Inport(i),'autorouting','on');
        set_param(Inport{i},'Position',[(modelInportPos(i,1)-100),(modelInportPos(i,2)-7.5),(modelInportPos(i,1)-70),(modelInportPos(i,2)+7.5)]);   
        namep = input{i+2,2};
        namep;
        if namep(8:8) == 'd'
            set_param(Inport{i},'OutDataTypeStr','UInt16');
        elseif namep(8:8) == 'g'
            set_param(Inport{i},'OutDataTypeStr','T_M_Nm_Float32');
        elseif namep(8:8) == 'y'
            set_param(Inport{i},'OutDataTypeStr','UInt8');
        else
            set_param(Inport{i},'OutDataTypeStr','UInt16');
        end
        set_param(Inport{i},'PortDimensions',input(i+2,6));
    else
        set_param(Inport{i},'Position',[(modelInportPos(i,1)-250),(modelInportPos(i,2)-80),(modelInportPos(i,1)-220),(modelInportPos(i,2)-65)]);
        add_line(module_name,h.Outport(1),h1.Trigger(1),'autorouting','on');	% Runaableλ�õ�������
    end
end
modelOutportPos = get_param(strcat(module_name,'/',module_name),'OutputPorts');
Outport = find_system(module_name,'SearchDepth',1,'BlockType','Outport');
for i=1:length(Outport)
    s = get_param(Outport{i},'PortConnectivity');
    add_line(module_name,[modelOutportPos(i,1),modelOutportPos(i,2);s.Position(1,1),s.Position(1,2)]);
    set_param(Outport{i},'Position',[(modelOutportPos(i,1)+70),(modelOutportPos(i,2)-7.5),(modelOutportPos(i,1)+100),(modelOutportPos(i,2)+7.5)])
    namep = output{i+2,2};
    if namep(8:8) == 'd'
        set_param(Outport{i},'OutDataTypeStr','UInt16');
    elseif namep(8:8) == 'g'
        set_param(Outport{i},'OutDataTypeStr','T_M_Nm_Float32');
    elseif namep(8:8) == 'y'
        set_param(Outport{i},'OutDataTypeStr','UInt8');       
    else
        set_param(Outport{i},'OutDataTypeStr','UInt16');
    end
    set_param(Outport{i},'PortDimensions',output(i+2,6));
end

for i=1:length(Inport)-1
    h = get_param(strcat(module_name,'/',Inport(i)),'PortHandles');
    h1 = get_param(strcat(module_name,'/',Inport(i),'_1'),'PortHandles');
    h2 = get_param(strcat(module_name,'/',Inport(i),'_2'),'PortHandles');
    add_line(strcat(module_name,'/',module_name),h.Outport(1),h1.Inport(1),'autorouting','on');
    add_line(strcat(module_name,'/',module_name),h1.Outport(1),h2.Inport(1),'autorouting','on');
end

for i=1:length(Outport)
    h1 = get_param(strcat(module_name,'/',Outport(i)),'PortHandles');
    h = get_param(strcat(module_name,'/',Outport(i),'_1'),'PortHandles');
    h2 = get_param(strcat(module_name,'/',Outport(i),'_2'),'PortHandles');
    add_line(strcat(module_name,'/',module_name),h.Outport(1),h1.Inport(1),'autorouting','on');
    add_line(strcat(module_name,'/',module_name),h2.Outport(1),h.Inport(1),'autorouting','on');
end
fprintf('4.Simulink�������\n');
set_param(StepName,'Port','1'); % ������ɺ�Ϊ�����������Runnable���ó�1

%% 4.����Autosar
fprintf('5.��ʼ����Autosar��������');
% �¿����Ĺ��ܣ������Խ׶Σ��޷�ȷ�����н�����Ƿ��ȶ�
autosar.api.delete(module_name);    % ɾ�����ڵ�Autosar����
fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b5.�����Զ�����autosar���ã���Լ��Ҫ1~2����...');
autosar.api.create(module_name,'default');   % ����Atuosar persepective 
fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b5.�����Զ�����autosar����...');
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

% ------------XmlĿ¼����------------ %
% Specify AUTOSAR application data type package path for XML export
TypePackage = get(arProps,'XmlOptions','DataTypePackage');
path = strings(12,1);
path(1) = strcat(TypePackage,'/ApplDataTypes');
path(2) = strcat(TypePackage,'/SwBaseTypes');
path(3) = strcat(TypePackage,'/DataTypeMappings');
path(4) = strcat(TypePackage,'/Ground');
path(5) = strcat(TypePackage,'/ApplDataTypes/DataConstrs');
path(6) = strcat(TypePackage,'/SystemConstants');
path(7) = strcat(TypePackage,'/SwAddrMethods');
path(8) = '/AUTOSAR/Services/Dcm';
path(9) = path(8);
path(10) = TypePackage;
path(11) = strcat(TypePackage,'/ApplDataTypes/RecordLayouts');
path(12) = path(8);
set(arProps,'XmlOptions','DataConstraintPackage',path(5));
set(arProps,'XmlOptions','ApplicationDataTypePackage',path(1));
set(arProps,'XmlOptions','SwBaseTypePackage',path(2));
set(arProps,'XmlOptions','DataTypeMappingPackage',path(3));
set(arProps,'XmlOptions','ConstantSpecificationPackage',path(4));
set(arProps,'XmlOptions','SystemConstantPackage',path(6));
set(arProps,'XmlOptions','SwAddressMethodPackage',path(7));
set(arProps,'XmlOptions','ModeDeclarationGroupPackage',path(8));
set(arProps,'XmlOptions','CompuMethodPackage',path(9));
set(arProps,'XmlOptions','UnitPackage',path(10));
set(arProps,'XmlOptions','SwRecordLayoutPackage',path(11));
set(arProps,'XmlOptions','InternalDataConstraintPackage',path(12));
set(arProps,'XmlOptions','InternalDataConstraintExport',true);
autosar.api.syncModel(module_name);
eval('clear all');
fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');
fprintf('5.Autosar�������\n');
fprintf('ģ�ʹ�����ϣ�����\n');