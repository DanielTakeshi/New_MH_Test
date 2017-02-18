function setdefault(name, value)
%SETDEFAULT Set a default value if a variable doesn't exist or is empty
%   setdefault(name, value)
  assert(exist('name', 'var') && isvarname(name), ...
         'First argument is not provided or is not a valid variable name.');
  if ~exist('value', 'var')
    value = [];
  end
  
  if evalin('caller', ...
            sprintf('~exist(''%s'', ''var'') || isempty(%s)', ...
                    name, name))
    assignin('caller', name, value);
  end
end
