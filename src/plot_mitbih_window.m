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
