function root = project_root()
%PROJECT_ROOT Retorna a raiz do projeto com base no local desta função.
% Ajuste os ".." conforme a sua estrutura.
%
% Exemplo esperado:
%   <root>/src/utils/project_root.m
%   => root = <root>

    here = fileparts(mfilename('fullpath'));
    root = fullfile(here, '..', '..');  % sobe de src/utils para a raiz
    root = char(java.io.File(root).getCanonicalPath()); % normaliza caminho
end
