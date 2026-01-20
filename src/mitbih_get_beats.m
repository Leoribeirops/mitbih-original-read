function B = mitbih_get_beats(S, opts)
%MITBIH_GET_BEATS Filtra anotações do MIT-BIH para batimentos (R-peak refs).
%
% Entrada:
%   S.ecg, S.fs, S.annSample, S.annType, S.record
%   opts.beatSymbols (opcional): cellstr de símbolos a manter
%
% Saída (struct B):
%   B.samples : amostras (1-based) dos batimentos
%   B.types   : símbolos correspondentes
%   B.record, B.fs

    if nargin < 2, opts = struct(); end

    if ~isfield(opts,'beatSymbols') || isempty(opts.beatSymbols)
        % Conjunto conservador de batimentos do MIT-BIH (ajuste conforme política)
        opts.beatSymbols = {'N','L','R','B','A','a','J','S','V','E','F','e','j','/','f','Q'};
        % Se você quiser comparar só "normais", use {'N'}.
    end

    annS = S.annSample(:);
    annT = S.annType;

    % Normaliza annType para char coluna (caso venha como cellstr)
    if iscell(annT)
        annT = char(annT);
    end
    annT = annT(:);

    keep = false(size(annS));
    for k = 1:numel(opts.beatSymbols)
        sym = opts.beatSymbols{k};
        keep = keep | (annT == sym);
    end

    B = struct();
    B.record  = S.record;
    B.fs      = S.fs;
    B.samples = annS(keep);
    B.types   = annT(keep);
end
