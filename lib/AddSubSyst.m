function AddSubSyst(syst_type, subsyst_name, syst_size)
    % AddSubSyst:添加子函数
    % @param
    %           syst_type：例如Subsystem或其他类型，目前仅支持普通子系统
    %       sub_syst_name: 子系统的完整名字模块名+子系统,例如：''untitled/Test','JABS/JABS'
    %           syst_size: 子系统默认大小
    if syst_type == 'Function-Call Subsystem'
        add_block('simulink/Ports & Subsystems/Function-Call Subsystem', subsyst_name, 'Position', syst_size);
        reg_subsyt(subsyst_name);
    end

    fprintf("[LOG]Function-Call SubSyst子系统创建完成\n");
end

function reg_subsyt(subsyst_name)
    % 删除子系统中元素
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

    % 删除子系统中的line
    l1 = find_system(subsyst_name, 'FindAll', 'on', 'type', 'line'); % 找到子模块连接线的handle
    delete_line(l1); % 删除相应线段
end
