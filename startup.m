function startup()
% STARTUP - versão simples
    % Limpa path global
    restoredefaultpath;

    % Obtém o nome do computador
hostname = getenv('COMPUTERNAME');   % Windows
hostname = strtrim(hostname);

if strcmpi(hostname, 'Desktop-LEO')
   projectRoot = pwd;
   fprintf('[STARTUP] Projeto inicializado em:\n%s\n', projectRoot);
   fprintf('Desktop');
   addpath(genpath('database'));
   addpath(genpath('src'));
   addpath(genpath('mcode'));
    
elseif strcmpi(hostname, 'Notebook-LEO')
   projectRoot = pwd;
   fprintf('[STARTUP] Projeto inicializado em:\n%s\n', projectRoot);
   fprintf('Notebook');
   addpath(genpath('database'));
   addpath(genpath('src'));
   addpath(genpath('mcode'));
   
else
    error('Computador não reconhecido: %s', hostname);
end

fprintf('[STARTUP] Projeto inicializado em:\n%s\n', projectRoot);


addpath(projectRoot);
%addpath(genpath(fullfile(projectRoot, 'src')));
%addpath(genpath(fullfile(projectRoot, 'scripts')));
%addpath(genpath(fullfile(projectRoot, 'config')));


end