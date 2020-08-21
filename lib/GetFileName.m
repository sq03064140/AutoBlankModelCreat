function FilePath = GetFileName(mode, SearchCondi)
    % GetFileName
    % Description:
    %   ��ȡ�ӿ�˵��������,֧������ģʽ
    % @param: mode 0,ֱ�Ӷ�ȡ��ͨ�����õ�Search������ȡ�ļ�;
    %         mode 1,ͨ��uigetifile���������ļ�
    % @param: SearchCondi=[Path,FileCondi] ���������������������� ���� '*.xlsx*'
    if mode == 0        % ͨ��uigetfile �ֶ�ѡȡ�ĵ�
        [File, Path] = uigetfile(SearchCondi);
        FilePath = fullfile(Path, File);
    elseif mode == 1    % ͨ��ls���������ĵ�
        File = ls(SearchCondi);
        [mm, ~] = size(File);

        if mm == 1  % ֻ�����õ�һ���ĵ�
            if ~contains(SearchCondi, '\')  % ���������У�������Ŀ¼
                FilePath = fullfile(pwd, File);
            else    % ���������к���Ŀ¼
                indx = strfind(SearchCondi,'\');
                subdirectory = SearchCondi(indx(1):indx(end));
                FilePath = fullfile(strcat(pwd,subdirectory), File);
            end
        elseif mm > 1 % ���������Ŀ��
            ss = sprintf("���ڸ���Ŀ���ļ�������[Ŀ���ļ�����ر�] ��[�����������]\n");
            for ii = 1:mm
                ss = [ss; sprintf("Ŀ���ļ�:%s\n", File(ii, :))];
            end
            ss = [ss; sprintf('---------------\n')];
            disp(ss);
            error("�޸ĺ���������.");
        else
            error("mode ģʽ����\n");
        end
    else
        error('���뺯��������˶�����');
    end
    fprintf("Ŀ���ļ�����Ŀ¼: [%s]\n", FilePath);
end