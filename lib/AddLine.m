function ret = AddLine(target_path)
    % AddLine �˴���ʾ�йش˺�����ժҪ
    %   @param: target_path ��Ҫ���ߵ�SubSystem���߻�ȡ
    ret = 0; % 0����ʱ�źųɹ�ƥ��
    aa = target_path{1}(1:(strfind(target_path, '/') - 1)); % ��ȡsyst��Ŀ¼
    bb = target_path{1}((strfind(target_path, '/') + 1):end);

    % ������������:�������ڽ��У������ģ������һ�����ⲿ�ӿڿ�ʼ����
    % PortCheck���ڸú����ڽ���,���ݸú������ؽ���پ����Ƿ���ҪCheck
    
    % Inport����
    modelInportPos = get_param(target_path, 'InputPorts');
    ins_swc_path      = find_system(aa, 'SearchDepth', 1, 'BlockType', 'Inport');
    ins_swc_port_name = GetPortName(ins_swc_path);      % SWC Inport��Path��Port��ȡ
    ins_sub_path  = find_system(target_path, 'SearchDepth', 1, 'BlockType', 'Inport');
    ins_sub_port_name = GetPortName(ins_sub_path);      % SubSys Inport��Path��Port��ȡ
    
    for ii = 1:length(ins_swc_path) % ����SWC��I/O�ӿ�
        for jj = 1:length(ins_sub_path) % ����SubSyst��I/O
            if strcmp(ins_swc_port_name{ii}, ins_sub_port_name{jj})
                %                 add_line(aa, strcat(ins_swc_port_name{ii},'/1'), strcat(bb,'/',string(jj)),'autorouting','on');
                add_line(aa, strcat(ins_swc_port_name{ii},'/1'), strcat(bb,'/',string(jj)));
                break;  %
            end
        end
        % Runnable��ģ�����ߣ�û��̫�õķ�ʽ�Ȳ��ø�ģʽ����)
        if contains(ins_swc_port_name{ii},'Runnable')
            s = get_param(ins_swc_path{ii}, 'PortConnectivity');
            add_line(aa, [s.Position(1, 1), s.Position(1, 2); modelInportPos(end, 1), modelInportPos(end, 2)]);
        end
    end
    if (length(ins_swc_path) ~= size(modelInportPos,1))
        fprintf("[LOG]ģ����������ӿ���Ŀ��ƥ��\n");
        ret = 1;
    end

    % Outport����
    % ע: ���ģ��Ա�ʱ,�����������ڽ���
    modelOutportPos = get_param(target_path, 'OutputPorts');
    outs_swc_path      = find_system(aa, 'SearchDepth', 1, 'BlockType', 'Outport');
    outs_swc_port_name = GetPortName(outs_swc_path);      % SWC Inport��Path��Port��ȡ
    outs_sub_path  = find_system(target_path, 'SearchDepth', 1, 'BlockType', 'Outport');
    outs_sub_port_name = GetPortName(outs_sub_path);      % SubSys Inport��Path��Port��ȡ
    
    for ii = 1:length(outs_swc_path) % ����SWC��I/O�ӿ�
        flg = 0;
        for jj = 1:length(outs_sub_path) % ����SubSyst��I/O
            if strcmp(outs_swc_port_name{ii}, outs_sub_port_name{jj})
                add_line(aa, strcat(bb,'/',string(jj)), strcat(outs_swc_port_name{ii},'/1'));
                flg = 1;
                break;  %
            end
        end
        if flg == 0
           fprintf("[LOG]��⵽δ��ƥ�䵽�ӿ�\n"); 
           ret = 1;
        end
    end
end
