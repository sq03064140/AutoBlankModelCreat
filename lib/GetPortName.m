function PortName = GetPortName(FindInport)
    % GetPortName
    %   Description：获取每个Inport名称
    %   @param: FindInport, 搜索到Inport的全名 ('JABS/IMAPve_x_xxX')
    %   @param：PorName，截取后Inport的名称 举例: 'IMAPve_x_xxX'
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
        error("函数[GetPortName]错误");
    end

end
