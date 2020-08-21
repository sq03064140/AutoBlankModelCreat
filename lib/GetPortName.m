function PortName = GetPortName(FindInport)
    % GetPortName
    %   Description����ȡÿ��Inport����
    %   @param: FindInport, ������Inport��ȫ�� ('JABS/IMAPve_x_xxX')
    %   @param��PorName����ȡ��Inport������ ����: 'IMAPve_x_xxX'
    n_dims = size(FindInport, 1);
    PortName = FindInport;
    if n_dims == 1
        Indx = strfind(FindInport, '/');
        PortName = FindInport(Indx(end) + 1:end);
    elseif n_dims > 1
        for ii = 1:n_dims
            tmp = FindInport{ii};
            Indx = strfind(tmp, '/');
            PortName{ii} = tmp(Indx(end) + 1:end);
        end
    else
        error("����[GetPortName]����");
    end

end
