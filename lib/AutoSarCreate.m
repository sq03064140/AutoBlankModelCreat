classdef AutoSarCreate < handle
    % AutoSarCreat 用来进行SWC的各类配置的AutoSar工具
    %   此处显示详细说明
    
    properties
        model_name
        file_path
        tmp
    end
    
    methods
        function obj = AutoSarCreate(ModuleName)
            % 构造函数,初始化
            %   AutoSarCreat() 
            obj.model_name = ModuleName;
        end
        function GetFilePath(obj,varargin)
            % GetFilePath 获取接口说明书的名称和路径
            %   varargin = 1 无输入->默认同一文件夹下
            %   varargin = 2 输入目标文件所在文件夹
%             narginchk(1,2);   % 下方已用 if...else... 限制因此此处没必要设置
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
               fprintf("Error:在目录[%s]下存在含模块[%s]同名的多个目标文件.\n",SearchKey,obj.model_name); 
               fprintf("目录下文件名:\n");
               for ii = 1:ndims(obj.file_path)
                   fprintf("目录下文件名:%s\n",obj.file_path(ii,:));
               end
               error("Error:请根据提示修正错误.");
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
%             if isequal(getFileName,'') % 防止选择空文件夹
%                 fprintf('no excel file in the path you selected\n');
%             elseif  m ~= 1
%                 fprintf('Exist more than 1 *.xlsx in this path\n');
%             else
%                 fprintf('Your Target .xlsx file is: [%s ]\n',getFileName);
%             end
%             FullName = strcat(pwd,'\IO_doc\',FileName);

        
        function outputArg = method1(obj,inputArg)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            outputArg = obj.Property1 + inputArg;
        end
    end
end

