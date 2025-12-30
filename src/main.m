clc; clear; 
%addpath(genpath(fullfile(pwd, 'mitbih-original-read'))); % ou aponte para a raiz do projeto 1 vez
cd('../database');
S = load_mitbih_record('100', 1);
cd('../src');
%plot_mitbih_window(S, 5, 10);

% Janela em amostras (ajuste conforme quiser)
n0 = 1;       % início (MATLAB é 1-based)
n1 = 2000;    % fim

% Plot da janela
plot_mitbih_window_samples(S, n0, n1);

% =========================
% Métricas de picos
% =========================

% Total de picos anotados no registro
num_total_peaks = numel(S.annSample);

% Total de picos normais ('N')
isNormal = (S.annType == 'N');
num_normal_peaks = sum(isNormal);

% Total de picos dentro da janela [n0, n1]
num_peaks_window = sum(S.annSample >= n0 & S.annSample <= n1);

% Picos normais dentro da janela
num_normal_peaks_window = sum(isNormal & ...
                              S.annSample >= n0 & ...
                              S.annSample <= n1);

% =========================
% Prints organizados
% =========================

fprintf('\n=== MIT-BIH Record %s ===\n', S.record);
fprintf('Total de picos anotados        : %d\n', num_total_peaks);
fprintf('Total de picos normais (N)     : %d\n', num_normal_peaks);
fprintf('---------------------------------\n');
fprintf('Janela analisada (amostras)    : [%d , %d]\n', n0, n1);
fprintf('Picos na janela                : %d\n', num_peaks_window);
fprintf('Picos normais na janela (N)    : %d\n\n', num_normal_peaks_window);



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

function plot_mitbih_window(S, t0, t1)
%PLOT_MITBIH_WINDOW Plota janela [t0,t1] em segundos e marca anotações.

    ecg = S.ecg; fs = S.fs;

    i0 = max(1, floor(t0*fs) + 1);
    i1 = min(length(ecg), floor(t1*fs) + 1);

    idx = i0:i1;
    t = (idx-1)/fs;

    ann = S.annSample;
    annWin = ann(ann >= i0 & ann <= i1);

    figure;
    plot(t, ecg(idx)); grid on; grid minor; hold on;
    stem((annWin-1)/fs, ecg(annWin), 'r', 'filled');

    title(sprintf('MIT-BIH %s | %.2f–%.2f s', S.record, t0, t1));
    xlabel('Tempo (s)'); ylabel('Amplitude');
    legend('ECG','Anotações','Location','best');
end

function plot_mitbih_window_samples(S, n0, n1)
%PLOT_MITBIH_WINDOW_SAMPLES
% Plota ECG entre as amostras [n0, n1] e marca as anotações (R-peaks).
%
% S  : struct retornado por load_mitbih_record
% n0 : amostra inicial (1-based)
% n1 : amostra final (1-based)

    ecg = S.ecg;
    fs  = S.fs;

    % Garantir limites válidos
    n0 = max(1, round(n0));
    n1 = min(length(ecg), round(n1));

    assert(n0 < n1, 'n0 deve ser menor que n1.');

    idx = n0:n1;
    t   = (idx-1)/fs;   % tempo apenas para eixo (opcional)

    % Anotações dentro da janela
    ann = S.annSample;
    annWin = ann(ann >= n0 & ann <= n1);

    figure;
    plot(t, ecg(idx)); grid on; grid minor; hold on;
    stem((annWin-1)/fs, ecg(annWin), 'r', 'filled');

    title(sprintf('MIT-BIH %s | amostras %d–%d', S.record, n0, n1));
    xlabel('Tempo (s)');
    ylabel('Amplitude');
    legend('ECG','R-Peak','Location','best');
end
