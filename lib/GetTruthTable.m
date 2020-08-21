function [OutputTable, PortNum] = GetTruthTable(InputTable, InInfo)
    % GetTruthTable version 200629
    % Description:
    %   Get I/O说明书中非空行和Port的数量
    %   InputTable: 由Excel文件中读取到的完整表格
    %   @param InInfo = 2x1, Info(1):StartLine, Info(2):NameCol
    StartLine = InInfo(1);
    NameCol = InInfo(2);
    inport_num = 0;
    [m, n] = size(InputTable);
    OutputTable = string(ones(1, n));

    for i = StartLine:m

        if ~isequal(InputTable(i, NameCol), '')
            OutputTable(inport_num + 1, :) = InputTable(i, :);
            inport_num = inport_num + 1;
        end

    end

    PortNum = inport_num;
    % fprintf('读取表格总接口数：[%d] \n', PortNum);
end