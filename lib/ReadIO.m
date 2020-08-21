function [ReadResult] = ReadIO(FileName, SheetNumb, ColRange)
    % 由SheetNumb和ColRange读取Excel表格
    %   此处显示详细说明
    % 导入电子表格中Input的数据,设置导入选项
    opts = spreadsheetImportOptions("NumVariables", 7);
    % 指定工作表和范围
    opts.Sheet = SheetNumb; %excel 第几页名称
    opts.DataRange = ColRange;
    % 指定列名称和类型
    opts.VariableNames = ["No", "ModuleInterface", "Description", "Data_type_T", "Dimension", "DataType", "Input"];
    opts.VariableTypes = ["string", "string", "string", "string", "string", "string", "string"];
    opts = setvaropts(opts, [1, 2, 3, 4, 5, 6, 7], "WhitespaceRule", "preserve");
    opts = setvaropts(opts, [1, 2, 3, 4, 5, 6, 7], "EmptyFieldRule", "auto");
    ReadTable = readtable(FileName, opts, "UseExcel", false); % 同一个文件夹相对路径
    % 清除临时变量
    clear opts
    ReadResult = table2array(ReadTable); % 类型转换输出读取结果
    % [mm, nn] = szie(ReadResult);
    % sprintf("[LOG]读取表格Table大小: [%d x %d]\n",mm,nn);
end
