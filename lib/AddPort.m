function AddPort(target_path, add_mode, port_info)
    % AddPort   Version.200707
    % Description:
    %   �����������Port(I/O����),�ú����������Լ���ʽ������ʱ�����뺯��
    %   @param:target_path Ŀ��path������������/���Ŀ¼��syst_name;��ϵͳ������/�����syst_name/module_name
    %   @param:mode, 1����Inport��2����Outport

    PortInterval = 35; % ����port֮ǰ���
    % ����add_modeȷ����Ҫ��ӵ�Port��In1����Out1
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

    % ����[port_info]ά��ѡ����Ҫ���Ԫ�أ�1,��������֣�2,���
    [ListNum, ListDims] = size(port_info); % ��������tableά���ж�Ӧ�������

    for ii = 1:ListNum
        PortName = port_info{ii, 1};
        PortPath = strcat(target_path, '/', PortName);
        PortPosition = [port_width(1) 100 + ii * PortInterval port_width(2) 115 + ii * PortInterval];

        try
            add_block(block_path, PortPath, 'Position', PortPosition);
        catch
            fprintf("[%s],���ʧ��,����:ɾ������port���������л�鿴��PortNum�Ƿ���ȷ\n", PortPath);
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
%     add_block('simulink/Commonly Used Blocks/Out1',strcat(subsyst_name,'/',OutName),'Position',[2050 100+i*PortInterval 2080 115+i*PortInterval]);  % Fucntion-call Subsyst ������ӿ�
% % end
% StepName = strcat(subsyst_name,'/','Runnable_',module_name,'_Step');
% add_block('simulink/Commonly Used Blocks/In1',StepName,'Position',[350 450 450 500]);
% set_param(StepName,'Port','1'); % ������ɺ�Ϊ�����������Runnable���ó�1

% % subsyst_name = strcat(module_name,'/',module_name);
% block_high = max(InListNum,OutListNum)*PortInterval;
% module_name = strcat(GetModuleName(output,OutNameCol));
% subsyst_name = strcat(file_name,'/',module_name);
% syst_size = [size(1) size(2) size(1)+size(3) size(2)+block_high];      %%
% AddSubSyst(subsyst_name,syst_size);