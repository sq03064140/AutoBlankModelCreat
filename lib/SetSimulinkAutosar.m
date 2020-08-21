function SetSimulinkAutosar(module_name)
    % ���ò���(�ɸ���ʵ�������в�������)
    step_size = '0.01'; % ���沽����һ�㲻���޸�
    stf = 'autosar.tlc';

    % ����simulink��code generation ����
    cs = getActiveConfigSet(module_name);
    set_param(cs, 'SolverType', 'Fixed-step'); % Solver����
    set_param(cs, 'FixedStep', step_size); % Solver����
    switchTarget(cs, stf, []); % ����ģ���ļ�������
    set_param(cs, 'DefaultUnderspecifiedDataType', 'single');   % ����Ĭ��ΪSingle
    set_param(cs, 'GenerateCodeMetricsReport', 'on');           % �����������ױ���
    set_param(cs, 'BlockReduction', 'off');                     % ���ɴ���ʱ�����м��ٽӿڵ��Ż�
    set_param(cs, 'AutosarSchemaVersion', '4.2');               % AutosarVersion = 4.2
    set_param(cs, 'AutosarMaxShortNameLength', 32);             % ����ʹ�����ֵ:32
    set_param(cs, 'GenerateASAP2', 'on');                       % ����ͨ��Э��
    %set_param(cs,'EfficientFloat2IntCast','on');               % ����װ��Χ��ֵ�Ĵ���Ӹ���ת���Ƴ�������ת�������ó�ON����ɷ���ʹ�������ͬ
    set_param(cs, 'InlineInvariantSignals', 'on');              % �������źŵķ�������ת��Ϊ����ֵ
    set_param(cs, 'CombineSignalStateStructs', 'on');           % �Ƿ������ɴ����У���ȫ�ֿ��źź�ȫ��״̬���ݺϲ���һ�����ݽṹ��
    set_param(cs, 'UseSpecifiedMinMax', 'on');                  % ʹ�ô�ģ�����źźͲ�������С�����ֵָ��ֵ�л�õķ�Χ��Ϣ�Ż����ɵĴ���
    set_param(cs, 'UseFloatMulNetSlope', 'on');                 % �����������ʹ�ø���˷��Ը��㵽����ת��ִ�о��¶�������
    set_param(cs, 'BuildConfiguration', 'Faster Runs');         % ѡ�񹤾�������Ĺ�������(�������)
    set_param(cs, 'OptimizationCustomize', 'on');               % Ϊ������ָ���������Ż����������
    set_param(cs, 'GlobalVariableUsage', 'None');               % ȫ�ֱ����Ż���ʹ��Ĭ�ϵ��Ż���
    %set_param(cs, 'ProdLongLongMode','on');                     % ֧��C long long��������
    set_param(cs,'UtilityFuncGeneration','Shared location');    % ָ��ʹ���Զ���洢������ʵ�ó������������������Ͷ���͵�������������λ��
    set_param(cs,'StateflowObjectComments','on');               % ����StateFlow�Ķ���ע��
    set_param(cs,'ReqsInCode','on');                            % �������������Ϊע�Ͳ��뵽���ɵĴ�����
    set_param(cs,'MATLABFcnDesc','on');                         % ��Matlab�е�ע�ͣ�Ҳ���뵽���ɴ�����
    %set_param(cs,'MATLABSourceComments','on');                  % ��Matlab��Դ����ΪԴ����뵽ע����
    set_param(cs,'LifeSpan','inf');                             % ����Ӧ�ó�����������ڡ����
    set_param(cs,'IntegerOverflowMsg','error');                 % ����źŵ�ֵ����ź��������ͣ����򱨴�(error)
    set_param(cs,'IntegerSaturationMsg','error');               % ��ģ������м�����ʱ�ź��Ƿ񱥺�,���ͺ�(error)
    set_param(cs,'ReadBeforeWriteMsg','EnableAllAsError');      % ģ����ͼ���ڴ�ʱ�䲽������δд�����ݵ����ݴ洢����ȡ���ݣ�ֹͣģ�Ⲣ�ڴ���Ի�������ʾ��Ͻ��
    set_param(cs,'WriteAfterReadMsg','EnableAllAsError');       % ģ����֮ǰ�ڵ�ǰʱ�䲽���ж�ȡ���ݺ���ͼ������д�����ݴ洢��ֹͣģ�Ⲣ�ڴ���Ի�������ʾ��Ͻ��
    set_param(cs,'WriteAfterWriteMsg','EnableAllAsError');      % ģ�ͳ����ڵ�ǰʱ�䲽�����������������ݴ洢д������
    set_param(cs,'NonBusSignalsTreatedAsBus','error');          % ���Simulink��ʱ����ʽ�������ź�ת��Ϊ�����ź���֧�ֽ��ź����ӵ����߷��������ѡ������
    set_param(cs,'SFInvalidInputDataAccessInChartInitDiag','error');
    set_param(cs,'SFTransitionOutsideNaturalParentDiag','error');
    set_param(cs,'SFUnreachableExecutionPathDiag','error');
    set_param(cs,'SFUndirectedBroadcastEventsDiag','error');
    set_param(cs,'AssertControl','DisableAll');
    set_param(cs,'EnableCustomComments','on');                  % ָ���Ƿ������ɵĴ����а���ģ��������(MPT)�źźͲ������ݶ�����Զ���ע��
    set_param(cs,'ParenthesesLevel','Maximum');                 % Ϊ���ɵĴ���ָ��������ʽ,���ֵ(������ָ�����ȼ�)
    set_param(cs,'UseDivisionForNetSlopeComputation','on');     % ��������Ժ�׼ȷ������ʱ��ʹ��fixed point Designer������ִ�о��¶ȼ��㣬�Դ����¶�
    set_param(cs,'EnableSignedLeftShifts','off');               % ָ���Ƿ����з��ŵ�λ��λ�滻2���ݳ˷�(MISRA�رպ�����м�����)
    set_param(cs,'EnableSignedRightShifts','off');              % ͬ�� Left/Right����
    set_param(cs,'CastingMode','Standards');                    % ָ���������������ת���������������ͣ���׼����
    set_param(cs,'GenerateSharedConstants','off');              % ���ƴ����������Ƿ����ɾ��й������͹������Ĵ���
    set_param(cs,'SignalInfNanChecking','error');               % ����������ֵ�ڵ�ǰʱ�䲽��ΪInf��NaN��ϵͳerror
    set_param(cs,'CompileTimeRecursionLimit',0);                % MATLAB�����ı���ʱ�ݹ��������������ڱ���ʱ�ݹ�������ɴ���������ĺ�������������Ϊ0
    %set_param(cs,'EnableRuntimeRecursion','off');
    set_param(cs,'Solver','FixedStepDiscrete');                 % ѡ��Ҫ������ģ�����������ڼ����ģ��״̬�������,�̶�������ɢ
    set_param(cs,'MultiTaskDSMMsg','error');                    % ���������ݴ洢������ڶ�������ж�ȡ��д������ݴ洢
    set_param(cs,'UniqueDataStoreMsg','error');                 % �ظ������ݴ洢���ƣ���������ݴ洢�ڴ���ʱʹ����ͬ�����ݴ洢����
    set_param(cs,'SFSimEcho','off');                            % û�зֺŵĻ��Ա��ʽ
    set_param(cs,'UpdateModelReferenceTargets','IfOutOfDate');  % �ڸ��¡�ģ���Ӹ�ģ�����ɴ���֮ǰ��ѡ������ȷ����ʱΪ����ģ���ؽ������SimulinkCoderĿ��ķ���
    set_param(cs,'ObjectivePriorities', {'Execution efficiency','ROM efficiency','RAM efficiency','Traceability','Safety precaution','Debugging','MISRA C:2012 guidelines','Polyspace'});

    fprintf("[LOG] Code generation�����������\n");

end
