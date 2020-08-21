function [module_name] = GetModuleName(OutputTable, NameCol)
    name_1 = OutputTable{1, NameCol};
    module_name = string(name_1(1:4));
    fprintf('[LOG]Your SWC name is :[%s]\n', module_name);
end
