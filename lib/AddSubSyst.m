function AddSubSyst(syst_type, subsyst_name, syst_size)
    % AddSubSyst:����Ӻ���
    % @param
    %           syst_type������Subsystem���������ͣ�Ŀǰ��֧����ͨ��ϵͳ
    %       sub_syst_name: ��ϵͳ����������ģ����+��ϵͳ,���磺''untitled/Test','JABS/JABS'
    %           syst_size: ��ϵͳĬ�ϴ�С
    if syst_type == 'Function-Call Subsystem'
        add_block('simulink/Ports & Subsystems/Function-Call Subsystem', subsyst_name, 'Position', syst_size);
        reg_subsyt(subsyst_name);
    end

    fprintf("[LOG]Function-Call SubSyst��ϵͳ�������\n");
end

function reg_subsyt(subsyst_name)
    % ɾ����ϵͳ��Ԫ��
    list_sub = find_system(subsyst_name);
    
    if length(list_sub) >= 2
        for ii = 2:length(list_sub)
            if strcmp(list_sub{ii}, 'JABS/JABS/function')
               continue
            else
               delete_block(list_sub{ii}); 
            end
        end
    end

    % ɾ����ϵͳ�е�line
    l1 = find_system(subsyst_name, 'FindAll', 'on', 'type', 'line'); % �ҵ���ģ�������ߵ�handle
    delete_line(l1); % ɾ����Ӧ�߶�
end
