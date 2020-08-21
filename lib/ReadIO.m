function [ReadResult] = ReadIO(FileName, SheetNumb, ColRange)
    % ��SheetNumb��ColRange��ȡExcel���
    %   �˴���ʾ��ϸ˵��
    % ������ӱ����Input������,���õ���ѡ��
    opts = spreadsheetImportOptions("NumVariables", 7);
    % ָ��������ͷ�Χ
    opts.Sheet = SheetNumb; %excel �ڼ�ҳ����
    opts.DataRange = ColRange;
    % ָ�������ƺ�����
    opts.VariableNames = ["No", "ModuleInterface", "Description", "Data_type_T", "Dimension", "DataType", "Input"];
    opts.VariableTypes = ["string", "string", "string", "string", "string", "string", "string"];
    opts = setvaropts(opts, [1, 2, 3, 4, 5, 6, 7], "WhitespaceRule", "preserve");
    opts = setvaropts(opts, [1, 2, 3, 4, 5, 6, 7], "EmptyFieldRule", "auto");
    ReadTable = readtable(FileName, opts, "UseExcel", false); % ͬһ���ļ������·��
    % �����ʱ����
    clear opts
    ReadResult = table2array(ReadTable); % ����ת�������ȡ���
    % [mm, nn] = szie(ReadResult);
    % sprintf("[LOG]��ȡ���Table��С: [%d x %d]\n",mm,nn);
end
