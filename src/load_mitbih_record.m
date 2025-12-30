function S = load_mitbih_record(record, channel)
%LOAD_MITBIH_RECORD Carrega MIT-BIH a partir de <root>/database.
% record : '100', '101', ...
% channel: 1 ou 2 (default 1)

    if nargin < 2 || isempty(channel)
        channel = 1;
    end

    record = char(record);

    % Base fixa do projeto
    dbRoot = fullfile(project_root(), 'database');

    assert(isfolder(dbRoot), 'Pasta database não encontrada em: %s', dbRoot);

    % Procura recursivamente pelo .hea do record dentro de database/
    hea = dir(fullfile(dbRoot, '**', [record '.hea']));
    assert(~isempty(hea), 'Não encontrei %s.hea dentro de %s (nem em subpastas).', record, dbRoot);

    recDir = hea(1).folder;

    % Confere se os outros arquivos estão juntos
    assert(isfile(fullfile(recDir, [record '.dat'])), '.dat não encontrado em %s', recDir);
    assert(isfile(fullfile(recDir, [record '.atr'])), '.atr não encontrado em %s', recDir);

    % Executa sem depender do Current Folder (mas entrando temporariamente na pasta do record)
    oldDir = pwd;
    c = onCleanup(@() cd(oldDir));
    cd(recDir);

    % Ajuda o WFDB Toolbox a resolver corretamente
    setenv('WFDB', recDir);

    % Lê sinal e anotações
    [signal, fs, tm] = rdsamp(record);
    [annSample, annType, annSubType, annChan, annNum, annComments] = rdann(record, 'atr'); %#ok<ASGLU>

    % Ajuste de indexação se vier base 0
    if ~isempty(annSample) && min(annSample) == 0
        annSample = annSample + 1;
    end

    assert(channel >= 1 && channel <= size(signal,2), 'Canal inválido.');
    ecg = signal(:, channel);

    % Retorno
    S = struct();
    S.ecg       = ecg(:);
    S.fs        = fs;
    S.tm        = tm(:);
    S.annSample = annSample(:);
    S.annType   = annType;
    S.record    = record;
    S.dbRoot    = dbRoot;
    S.recDir    = recDir;
end
