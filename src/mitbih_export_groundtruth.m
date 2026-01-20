function out = mitbih_export_groundtruth(records, channel, outDir, opts)
%MITBIH_EXPORT_GROUNDTRUTH Exporta R-peak ground truth do MIT-BIH.
%
% Salva:
%   <record>_gt.mat  (struct GT)
%   <record>_gt.csv  (colunas: sample,type)
%   summary_gt.csv   (contagens por registro)

    if nargin < 2 || isempty(channel), channel = 1; end
    if nargin < 3 || isempty(outDir)
        outDir = fullfile(project_root(), 'groundtruth');
    end
    if nargin < 4, opts = struct(); end

    if ~isfolder(outDir), mkdir(outDir); end

    summary = [];

    for i = 1:numel(records)
        rec = records{i};

        % Reusa seu loader
        S = load_mitbih_record(rec, channel);

        % Filtra batimentos
        B = mitbih_get_beats(S, opts);

        % Monta GT
        GT = struct();
        GT.record   = rec;
        GT.channel  = channel;
        GT.fs       = S.fs;
        GT.samples  = B.samples;           % 1-based
        GT.types    = B.types;             % char
        GT.nBeats   = numel(B.samples);

        % Salva .mat
        save(fullfile(outDir, sprintf('%s_gt.mat', rec)), 'GT');

        % Salva .csv
        T = table(GT.samples, cellstr(GT.types), 'VariableNames', {'sample','type'});
        writetable(T, fullfile(outDir, sprintf('%s_gt.csv', rec)));

        % Summary
        summary = [summary; {rec, GT.nBeats}]; %#ok<AGROW>
        fprintf('[GT] %s | beats=%d | fs=%g\n', rec, GT.nBeats, GT.fs);
    end

    summaryT = cell2table(summary, 'VariableNames', {'record','nBeats'});
    writetable(summaryT, fullfile(outDir, 'summary_gt.csv'));

    out = struct();
    out.outDir = outDir;
    out.summary = summaryT;
end
