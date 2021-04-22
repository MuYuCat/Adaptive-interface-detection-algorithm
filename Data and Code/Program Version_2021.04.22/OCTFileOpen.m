function [ handle ] = OCTFileOpen( filename )
% OCTFILEOPEN  Open .oct file.
%   handle = OCTFILEOPEN( filename ) Open .oct file located at filename
%
%   The data files inside the .oct file are extracted into the temporary
%   directory and removed when OCTFileClose is called
%
%   See also OCTFILECLOSE
%

handle.filename = filename;
%handle.path = [pwd, '\OCTData\'];
handle.path = [tempdir, 'OCTData\'];

if exist(handle.path,'file')
   rmdir(handle.path, 's')  %Rmdir 删除目录
end
if ~exist(handle.path,'file')
   mkdir(handle.path, 's')  %Rmdir 创建目录
end
unzip(filename, handle.path);%解压缩，文件名，文件路径
handle.xml = xmlread([handle.path, 'Header.xml']);% 读取 XML 文档并返回文档对象模型节点(xml文档中<>的部分)
head_oct = xml2struct([handle.path, 'Header.xml']);
handle.head = head_oct.Ocity;

end

