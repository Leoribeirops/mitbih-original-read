clc; clear;

record = '100';

% Pasta onde estão 100.hea / 100.dat / 100.atr
pnDir = 'C:\wfdp-app=toolbox2\database';

% Valida se os arquivos existem
assert(isfile(fullfile(pnDir,[record '.hea'])), '.hea não encontrado');
assert(isfile(fullfile(pnDir,[record '.dat'])), '.dat não encontrado');
assert(isfile(fullfile(pnDir,[record '.atr'])), '.atr não encontrado');

% Define o caminho WFDB (onde o toolbox vai procurar)
setenv('WFDB', pnDir);

% Chame com o NOME do record (não passe caminho completo)
[signal, Fs, tm] = rdsamp(record);
[annSample, annType, annSubType, annChan, annNum, annComments] = rdann(record,'atr');

% Ajuste se vier index base 0
if ~isempty(annSample) && min(annSample)==0
    annSample = annSample + 1;
end

% Plot rápido para checar se as marcações caem nos picos R
ecg = signal(:,1);
figure; plot(ecg); hold on; grid on;
stem(annSample(1:10), ecg(annSample(1:10)), 'r', 'filled');
title(sprintf('MIT-BIH %s: ECG com anotações (primeiros 10)', record));
xlabel('Amostras'); ylabel('Amplitude');
legend('ECG','Anotações');
