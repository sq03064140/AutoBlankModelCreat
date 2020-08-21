function FilePath = GetFileName(mode, SearchCondi)
    % GetFileName
    % Description:
    %   获取接口说明书名称,支持两种模式
    % @param: mode 0,直接读取并通过设置的Search条件获取文件;
    %         mode 1,通过uigetifile命令搜索文件
    % @param: SearchCondi=[Path,FileCondi] 搜索条件，传入搜索条件 例如 '*.xlsx*'
    if mode == 0        % 通过uigetfile 手动选取文档
        [File, Path] = uigetfile(SearchCondi);
        FilePath = fullfile(Path, File);
    elseif mode == 1    % 通过ls智能搜索文档
        File = ls(SearchCondi);
        [mm, ~] = size(File);

        if mm == 1  % 只搜索得到一个文档
            if ~contains(SearchCondi, '\')  % 搜索条件中，不含子目录
                FilePath = fullfile(pwd, File);
            else    % 搜索条件中含子目录
                indx = strfind(SearchCondi,'\');
                subdirectory = SearchCondi(indx(1):indx(end));
                FilePath = fullfile(strcat(pwd,subdirectory), File);
            end
        elseif mm > 1 % 搜索到多个目标
            ss = sprintf("存在复数目标文件，请检查[目标文件打开请关闭] 或[检查搜索条件]\n");
            for ii = 1:mm
                ss = [ss; sprintf("目标文件:%s\n", File(ii, :))];
            end
            ss = [ss; sprintf('---------------\n')];
            disp(ss);
            error("修改后重新运行.");
        else
            error("mode 模式错误\n");
        end
    else
        error('传入函数错误，请核对问题');
    end
    fprintf("目标文件完整目录: [%s]\n", FilePath);
end