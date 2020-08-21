classdef AutoSarCreate < handle
    % AutoSarCreat ��������SWC�ĸ������õ�AutoSar����
    %   �˴���ʾ��ϸ˵��
    
    properties
        model_name
        file_path
        tmp
    end
    
    methods
        function obj = AutoSarCreate(ModuleName)
            % ���캯��,��ʼ��
            %   AutoSarCreat() 
            obj.model_name = ModuleName;
        end
        function GetFilePath(obj,varargin)
            % GetFilePath ��ȡ�ӿ�˵��������ƺ�·��
            %   varargin = 1 ������->Ĭ��ͬһ�ļ�����
            %   varargin = 2 ����Ŀ���ļ������ļ���
%             narginchk(1,2);   % �·����� if...else... ������˴˴�û��Ҫ����
            if nargin == 1
                SearchKey = strcat(pwd,'\*',obj.model_name,'*.xlsx*');
            elseif nargin == 2
                sub_path = varargin{1};
                SearchKey = strcat(pwd,'\',sub_path,'\*',obj.model_name,'*.xlsx*');
            else
                error("Error:Out of Input dimension.");
            end
            obj.file_path=ls(SearchKey);
            if ndims(obj.file_path) > 1
               fprintf("Error:��Ŀ¼[%s]�´��ں�ģ��[%s]ͬ���Ķ��Ŀ���ļ�.\n",SearchKey,obj.model_name); 
               fprintf("Ŀ¼���ļ���:\n");
               for ii = 1:ndims(obj.file_path)
                   fprintf("Ŀ¼���ļ���:%s\n",obj.file_path(ii,:));
               end
               error("Error:�������ʾ��������.");
            end
          end              
           
%             FileName = [];
%             % if mode == 1
%             getFileName=ls(strcat(pwd,'\IO_doc\*',model_name,'*.xlsx*'));
%             [m, ~] = size(getFileName);
%             if m == 1
%                 FileName = getFileName;
%             else
%                 FileName = getFileName(1,:);
%             end
%             % else
%             %     [file,FileName] = uigetfile('*.xlsx');
%             % end
%             
%             if isequal(getFileName,'') % ��ֹѡ����ļ���
%                 fprintf('no excel file in the path you selected\n');
%             elseif  m ~= 1
%                 fprintf('Exist more than 1 *.xlsx in this path\n');
%             else
%                 fprintf('Your Target .xlsx file is: [%s ]\n',getFileName);
%             end
%             FullName = strcat(pwd,'\IO_doc\',FileName);

        
        function outputArg = method1(obj,inputArg)
            %METHOD1 �˴���ʾ�йش˷�����ժҪ
            %   �˴���ʾ��ϸ˵��
            outputArg = obj.Property1 + inputArg;
        end
    end
end

