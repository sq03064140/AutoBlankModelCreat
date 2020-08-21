function ret = AddLine(target_path)
    % AddLine 此处显示有关此函数的摘要
    %   @param: target_path 需要连线的SubSystem连线获取
    ret = 0; % 0连接时信号成功匹配
    aa = target_path{1}(1:(strfind(target_path, '/') - 1)); % 获取syst的目录
    bb = target_path{1}((strfind(target_path, '/') + 1):end);

    % 设置连线问题:由外往内进行，如进行模块增减一般是外部接口开始进行
    % PortCheck不在该函数内进行,根据该函数返回结果再决定是否需要Check
    
    % Inport连线
    modelInportPos = get_param(target_path, 'InputPorts');
    ins_swc_path      = find_system(aa, 'SearchDepth', 1, 'BlockType', 'Inport');
    ins_swc_port_name = GetPortName(ins_swc_path);      % SWC Inport的Path和Port获取
    ins_sub_path  = find_system(target_path, 'SearchDepth', 1, 'BlockType', 'Inport');
    ins_sub_port_name = GetPortName(ins_sub_path);      % SubSys Inport的Path和Port获取
    
    for ii = 1:length(ins_swc_path) % 遍历SWC的I/O接口
        for jj = 1:length(ins_sub_path) % 遍历SubSyst的I/O
            if strcmp(ins_swc_port_name{ii}, ins_sub_port_name{jj})
                %                 add_line(aa, strcat(ins_swc_port_name{ii},'/1'), strcat(bb,'/',string(jj)),'autorouting','on');
                add_line(aa, strcat(ins_swc_port_name{ii},'/1'), strcat(bb,'/',string(jj)));
                break;  %
            end
        end
        % Runnable的模块连线（没有太好的方式先采用该模式连接)
        if contains(ins_swc_port_name{ii},'Runnable')
            s = get_param(ins_swc_path{ii}, 'PortConnectivity');
            add_line(aa, [s.Position(1, 1), s.Position(1, 2); modelInportPos(end, 1), modelInportPos(end, 2)]);
        end
    end
    if (length(ins_swc_path) ~= size(modelInportPos,1))
        fprintf("[LOG]模块内外输入接口数目不匹配\n");
        ret = 1;
    end

    % Outport连线
    % 注: 输出模块对比时,还是由外向内进行
    modelOutportPos = get_param(target_path, 'OutputPorts');
    outs_swc_path      = find_system(aa, 'SearchDepth', 1, 'BlockType', 'Outport');
    outs_swc_port_name = GetPortName(outs_swc_path);      % SWC Inport的Path和Port获取
    outs_sub_path  = find_system(target_path, 'SearchDepth', 1, 'BlockType', 'Outport');
    outs_sub_port_name = GetPortName(outs_sub_path);      % SubSys Inport的Path和Port获取
    
    for ii = 1:length(outs_swc_path) % 遍历SWC的I/O接口
        flg = 0;
        for jj = 1:length(outs_sub_path) % 遍历SubSyst的I/O
            if strcmp(outs_swc_port_name{ii}, outs_sub_port_name{jj})
                add_line(aa, strcat(bb,'/',string(jj)), strcat(outs_swc_port_name{ii},'/1'));
                flg = 1;
                break;  %
            end
        end
        if flg == 0
           fprintf("[LOG]检测到未被匹配到接口\n"); 
           ret = 1;
        end
    end
end
