function SetSimulinkAutosar(module_name)
    % 设置参数(可根据实际需求有参数传入)
    step_size = '0.01'; % 仿真步长，一般不需修改
    stf = 'autosar.tlc';

    % 设置simulink的code generation 参数
    cs = getActiveConfigSet(module_name);
    set_param(cs, 'SolverType', 'Fixed-step'); % Solver设置
    set_param(cs, 'FixedStep', step_size); % Solver设置
    switchTarget(cs, stf, []); % 设置模型文件及属性
    set_param(cs, 'DefaultUnderspecifiedDataType', 'single');   % 设置默认为Single
    set_param(cs, 'GenerateCodeMetricsReport', 'on');           % 设置生成配套报告
    set_param(cs, 'BlockReduction', 'off');                     % 生成代码时不进行减少接口的优化
    set_param(cs, 'AutosarSchemaVersion', '4.2');               % AutosarVersion = 4.2
    set_param(cs, 'AutosarMaxShortNameLength', 32);             % 名称使用最大值:32
    set_param(cs, 'GenerateASAP2', 'on');                       % 采用通信协议
    %set_param(cs,'EfficientFloat2IntCast','on');               % 将包装范围外值的代码从浮点转换移除到整数转换，设置成ON会造成仿真和代码结果不同
    set_param(cs, 'InlineInvariantSignals', 'on');              % 将不变信号的符号名称转换为常数值
    set_param(cs, 'CombineSignalStateStructs', 'on');           % 是否在生成代码中，将全局块信号和全局状态数据合并到一个数据结构中
    set_param(cs, 'UseSpecifiedMinMax', 'on');                  % 使用从模型中信号和参数的最小和最大值指定值中获得的范围信息优化生成的代码
    set_param(cs, 'UseFloatMulNetSlope', 'on');                 % 定点设计器，使用浮点乘法对浮点到定点转换执行净坡度修正。
    set_param(cs, 'BuildConfiguration', 'Faster Runs');         % 选择工具链定义的构建配置(运行最快)
    set_param(cs, 'OptimizationCustomize', 'on');               % 为工具链指定编译器优化或调试设置
    set_param(cs, 'GlobalVariableUsage', 'None');               % 全局变量优化，使用默认的优化。
    %set_param(cs, 'ProdLongLongMode','on');                     % 支持C long long数据类型
    set_param(cs,'UtilityFuncGeneration','Shared location');    % 指定使用自定义存储类生成实用程序函数、导出数据类型定义和导出数据声明的位置
    set_param(cs,'StateflowObjectComments','on');               % 插入StateFlow的对向注释
    set_param(cs,'ReqsInCode','on');                            % 将输入的需求作为注释插入到生成的代码中
    set_param(cs,'MATLABFcnDesc','on');                         % 将Matlab中的注释，也插入到生成代码中
    %set_param(cs,'MATLABSourceComments','on');                  % 将Matlab的源码做为源码插入到注释中
    set_param(cs,'LifeSpan','inf');                             % 生成应用程序的生命周期【无穷】
    set_param(cs,'IntegerOverflowMsg','error');                 % 如果信号的值溢出信号数据类型，程序报错(error)
    set_param(cs,'IntegerSaturationMsg','error');               % 在模拟过程中检测溢出时信号是否饱和,饱和后(error)
    set_param(cs,'ReadBeforeWriteMsg','EnableAllAsError');      % 模型试图从在此时间步骤中尚未写入数据的数据存储区读取数据，停止模拟并在错误对话框中显示诊断结果
    set_param(cs,'WriteAfterReadMsg','EnableAllAsError');       % 模型在之前在当前时间步骤中读取数据后试图将数据写入数据存储，停止模拟并在错误对话框中显示诊断结果
    set_param(cs,'WriteAfterWriteMsg','EnableAllAsError');      % 模型尝试在当前时间步骤中连续两次向数据存储写入数据
    set_param(cs,'NonBusSignalsTreatedAsBus','error');          % 检测Simulink何时将隐式非总线信号转换为总线信号以支持将信号连接到总线分配或总线选择器块
    set_param(cs,'SFInvalidInputDataAccessInChartInitDiag','error');
    set_param(cs,'SFTransitionOutsideNaturalParentDiag','error');
    set_param(cs,'SFUnreachableExecutionPathDiag','error');
    set_param(cs,'SFUndirectedBroadcastEventsDiag','error');
    set_param(cs,'AssertControl','DisableAll');
    set_param(cs,'EnableCustomComments','on');                  % 指定是否在生成的代码中包含模块打包工具(MPT)信号和参数数据对象的自定义注释
    set_param(cs,'ParenthesesLevel','Maximum');                 % 为生成的代码指定括号样式,最大值(用括号指定优先级)
    set_param(cs,'UseDivisionForNetSlopeComputation','on');     % 当满足简单性和准确性条件时，使用fixed point Designer除法来执行净坡度计算，以处理净坡度
    set_param(cs,'EnableSignedLeftShifts','off');               % 指定是否用有符号的位移位替换2的幂乘法(MISRA关闭后更具有兼容性)
    set_param(cs,'EnableSignedRightShifts','off');              % 同上 Left/Right区别
    set_param(cs,'CastingMode','Standards');                    % 指定代码生成器如何转换变量的数据类型，标准兼容
    set_param(cs,'GenerateSharedConstants','off');              % 控制代码生成器是否生成具有共享常量和共享函数的代码
    set_param(cs,'SignalInfNanChecking','error');               % 如果块输出的值在当前时间步长为Inf或NaN，系统error
    set_param(cs,'CompileTimeRecursionLimit',0);                % MATLAB函数的编译时递归限制描述，对于编译时递归控制生成代码中允许的函数副本数量，为0
    %set_param(cs,'EnableRuntimeRecursion','off');
    set_param(cs,'Solver','FixedStepDiscrete');                 % 选择要用于在模拟或代码生成期间计算模型状态的求解器,固定步长离散
    set_param(cs,'MultiTaskDSMMsg','error');                    % 多任务数据存储，检测在多个任务中读取和写入的数据存储
    set_param(cs,'UniqueDataStoreMsg','error');                 % 重复的数据存储名称，检测多个数据存储内存块何时使用相同的数据存储名称
    set_param(cs,'SFSimEcho','off');                            % 没有分号的回显表达式
    set_param(cs,'UpdateModelReferenceTargets','IfOutOfDate');  % 在更新、模拟或从该模型生成代码之前，选择用于确定何时为引用模型重建仿真和SimulinkCoder目标的方法
    set_param(cs,'ObjectivePriorities', {'Execution efficiency','ROM efficiency','RAM efficiency','Traceability','Safety precaution','Debugging','MISRA C:2012 guidelines','Polyspace'});

    fprintf("[LOG] Code generation参数设置完成\n");

end
