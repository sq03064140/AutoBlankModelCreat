function AddPort(target_path, add_mode, port_info)
    % AddPort   Version.200707
    % Description:
    %   根据需求添加Port(I/O都可),该函数输入有自己格式，调用时将输入函数
    %   @param:target_path 目标path，例如总输入/输出目录：syst_name;子系统的输入/输出，syst_name/module_name
    %   @param:mode, 1设置Inport，2设置Outport

    PortInterval = 35; % 设置port之前间隔
    % 根据add_mode确定需要添加的Port是In1还是Out1
    if add_mode == 1
        block_type = 'In1';
        port_width = [50, 80];
    elseif add_mode == 2
        block_type = 'Out1';
        port_width = [1150, 1180];
    else
        error('Error. \nAddPort function input mode wrong, not a %s.', class(add_mode));
    end

    block_path = ['simulink/Commonly Used Blocks/' block_type];

    % 根据[port_info]维度选择需要添加元素：1,仅添加名字：2,添加
    [ListNum, ListDims] = size(port_info); % 根据输入table维度判断应如何设置

    for ii = 1:ListNum
        PortName = port_info{ii, 1};
        PortPath = strcat(target_path, '/', PortName);
        PortPosition = [port_width(1) 100 + ii * PortInterval port_width(2) 115 + ii * PortInterval];

        try
            add_block(block_path, PortPath, 'Position', PortPosition);
        catch
            fprintf("[%s],添加失败,建议:删除所有port后重新运行或查看各PortNum是否正确\n", PortPath);
        end

        if ListDims == 2
            PortType = port_info{ii, 2};
            set_param(PortPath, 'OutDataTypeStr', PortType);
        elseif ListDims == 3
            PortType = port_info{ii, 2};
            set_param(PortPath, 'OutDataTypeStr', PortType);
            PortDim  = port_info{ii, 3};
            set_param(PortPath, 'PortDimensions', PortDim);
        end

    end

end

% for i=1:OutListNum
%     OutName =  output{i,OutNameCol};
%     add_block('simulink/Commonly Used Blocks/Out1',strcat(subsyst_name,'/',OutName),'Position',[2050 100+i*PortInterval 2080 115+i*PortInterval]);  % Fucntion-call Subsyst 的输出接口
% % end
% StepName = strcat(subsyst_name,'/','Runnable_',module_name,'_Step');
% add_block('simulink/Commonly Used Blocks/In1',StepName,'Position',[350 450 450 500]);
% set_param(StepName,'Port','1'); % 规整完成后，为方便后续，将Runnable设置成1

% % subsyst_name = strcat(module_name,'/',module_name);
% block_high = max(InListNum,OutListNum)*PortInterval;
% module_name = strcat(GetModuleName(output,OutNameCol));
% subsyst_name = strcat(file_name,'/',module_name);
% syst_size = [size(1) size(2) size(1)+size(3) size(2)+block_high];      %%
% AddSubSyst(subsyst_name,syst_size);