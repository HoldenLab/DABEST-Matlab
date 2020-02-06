classdef DabestViolin < handle
    % DabestViolin creates violin plots for some data
    %   A violin plot is an easy to read substitute for a box plot
    %   that replaces the box shape with a kernel density estimate of
    %   the data, and optionally overlays the data points itself.
    %
    %   Additional constructor parameters include the width of the
    %   plot, the bandwidth of the kernel density estimation, and the
    %   X-axis position of the violin plot.
    %
    %   Use <a href="matlab:help('violinplot')">violinplot</a> for a
    %   <a href="matlab:help('boxplot')">boxplot</a>-like wrapper for
    %   interactive plotting.
    %
    %   See for more information on DabestViolin Plots:
    %   J. L. Hintze and R. D. Nelson, "DabestViolin plots: a box
    %   plot-density trace synergism," The American Statistician, vol.
    %   52, no. 2, pp. 181-184, 1998.
    %
    % DabestViolin Properties:
    %    DabestViolinColor - Fill color of the violin area and data points.
    %                  Defaults to the next default color cycle.
    %    DabestViolinAlpha - Transparency of the ciolin area and data points.
    %                  Defaults to 0.3.
    %    EdgeColor   - Color of the violin area outline.
    %                  Defaults to [0.5 0.5 0.5]
    %    BoxColor    - Color of the box, whiskers, and the outlines of
    %                  the median point and the notch indicators.
    %                  Defaults to [0.5 0.5 0.5]
    %    MedianColor - Fill color of the median and notch indicators.
    %                  Defaults to [1 1 1]
    %    ShowData    - Whether to show data points.
    %                  Defaults to true
    %    ShowNotches - Whether to show notch indicators.
    %                  Defaults to false
    %    ShowMean    - Whether to show mean indicator.
    %                  Defaults to false
    %
    % DabestViolin Children:
    %    ScatterPlot - <a href="matlab:help('scatter')">scatter</a> plot of the data points
    %    DabestViolinPlot  - <a href="matlab:help('fill')">fill</a> plot of the kernel density estimate
    %    BoxPlot     - <a href="matlab:help('fill')">fill</a> plot of the box between the quartiles
    %    WhiskerPlot - line <a href="matlab:help('plot')">plot</a> between the whisker ends
    %    MedianPlot  - <a href="matlab:help('scatter')">scatter</a> plot of the median (one point)
    %    NotchPlots  - <a href="matlab:help('scatter')">scatter</a> plots for the notch indicators
    %    MeanPlot    - line <a href="matlab:help('plot')">plot</a> at mean value

    % Copyright (c) 2016, Bastian Bechtold
    % This code is released under the terms of the BSD 3-clause license

    properties
        ScatterPlot % scatter plot of the data points
        DabestViolinPlot  % fill plot of the kernel density estimate
        BoxPlot     % fill plot of the box between the quartiles
        WhiskerPlot % line plot between the whisker ends
        MedianPlot  % scatter plot of the median (one point)
        NotchPlots  % scatter plots for the notch indicators
        MeanPlot    % line plot of the mean (horizontal line)
    end

    properties (Dependent=true)
        DabestViolinColor % fill color of the violin area and data points
        DabestViolinAlpha % transparency of the violin area and data points
        EdgeColor   % color of the violin area outline
        BoxColor    % color of box, whiskers, and median/notch edges
        BoxWidth    % width of box between the quartiles in axis space (default 10% of DabestViolin plot width, 0.03)
        MedianColor % fill color of median and notches
        ShowData    % whether to show data points
        ShowNotches % whether to show notch indicators
        ShowMean    % whether to show mean indicator
    end

    methods
        function obj = DabestViolin(data, pos, trueMedianDiff, varargin)
            %DabestViolin plots a violin plot of some data at pos
            %   VIOLIN(DATA, POS) plots a violin at x-position POS for
            %   a vector of DATA points.
            %
            %   VIOLIN(..., 'PARAM1', val1, 'PARAM2', val2, ...)
            %   specifies optional name/value pairs:
            %     'Width'        Width of the violin in axis space.
            %                    Defaults to 0.3
            %     'Bandwidth'    Bandwidth of the kernel density
            %                    estimate. Should be between 10% and
            %                    40% of the data range.
            %     'DabestViolinColor'  Fill color of the violin area and
            %                    data points. Defaults to the next
            %                    default color cycle.
            %     'DabestViolinAlpha'  Transparency of the violin area and
            %                    data points. Defaults to 0.3.
            %     'EdgeColor'    Color of the violin area outline.
            %                    Defaults to [0.5 0.5 0.5]
            %     'BoxColor'     Color of the box, whiskers, and the
            %                    outlines of the median point and the
            %                    notch indicators. Defaults to
            %                    [0.5 0.5 0.5]
            %     'MedianColor'  Fill color of the median and notch
            %                    indicators. Defaults to [1 1 1]
            %     'ShowData'     Whether to show data points.
            %                    Defaults to true
            %     'ShowNotches'  Whether to show notch indicators.
            %                    Defaults to false
            %     'ShowMean'     Whether to show mean indicator.
            %                    Defaults to false

            args = obj.checkInputs(data, pos, trueMedianDiff,varargin{:});
            data = data(not(isnan(data)));
            if numel(data) == 1
                obj.MedianPlot = scatter(pos, data, 'filled');
                obj.MedianColor = args.MedianColor;
                obj.MedianPlot.MarkerEdgeColor = args.EdgeColor;
                return
            end

            hold('on');

            % calculate kernel density estimation for the violin
            [density, value] = ksdensity(data, 'bandwidth', args.Bandwidth);
            density = density(value >= min(data) & value <= max(data));
            value = value(value >= min(data) & value <= max(data));
            value(1) = min(data);
            value(end) = max(data);

            % all data is identical
            if min(data) == max(data)
                density = 1;
            end

            width = args.Width/max(density);

            % plot the data points within the violin area
            if length(density) > 1
                jitterstrength = interp1(value, density*width, data);
            else % all data is identical:
                jitterstrength = density*width;
            end
            jitter = 2*(rand(size(data))-0.5);
            obj.ScatterPlot = ...
                scatter(pos + jitter.*jitterstrength, data, 'filled');

            %% plot the violin
            %obj.DabestViolinPlot =  ... % plot color will be overwritten later
            %    fill([pos+density*width pos-density(end:-1:1)*width], ...
            %         [value value(end:-1:1)], [1 1 1]);
            
            %one sided violin
            % plot the violin
            obj.DabestViolinPlot =  ... % plot color will be overwritten later
                fill([pos, pos+density*width, pos ], ...
                [value(1) value value(end)], [1 1 1]);

            % plot the mini-boxplot within the violin
            quartiles = quantile(data, [0.25, 0.5, 0.75]);         
            quantile95 = quantile(data, [0.05, 0.95]);         
            obj.BoxPlot = ... % plot color will be overwritten later
                fill(pos+[-1,1,1,-1]*args.BoxWidth, ...
                     [quantile95(1) quantile95(1) quantile95(2) quantile95(2)], ...
                     [1 1 1]);
                 
            % plot the data mean
            meanValue = mean(data);
            if length(density) > 1
                meanDensityWidth = interp1(value, density, meanValue)*width;
            else % all data is identical:
                meanDensityWidth = density*width;
            end
            if meanDensityWidth<args.BoxWidth/2
                meanDensityWidth=args.BoxWidth/2;
            end
            obj.MeanPlot = plot(pos+[-1,1].*meanDensityWidth, ...
                                [meanValue, meanValue]);
            obj.MeanPlot.LineWidth = 1;
                 
            IQR = quartiles(3) - quartiles(1);
            %lowhisker = quartiles(1) - 1.5*IQR;
            %lowhisker = max(lowhisker, min(data(data > lowhisker)));
            %hiwhisker = quartiles(3) + 1.5*IQR;
            %hiwhisker = min(hiwhisker, max(data(data < hiwhisker)));
            %if ~isempty(lowhisker) && ~isempty(hiwhisker)
            %    obj.WhiskerPlot = plot([pos pos], [lowhisker hiwhisker]);
            %end
            obj.MedianPlot = scatter(pos, trueMedianDiff, [], [1 1 1], 'filled');

            obj.NotchPlots = ...
                 scatter(pos, quartiles(2)-1.57*IQR/sqrt(length(data)), ...
                         [], [1 1 1], 'filled', '^');
            obj.NotchPlots(2) = ...
                 scatter(pos, quartiles(2)+1.57*IQR/sqrt(length(data)), ...
                         [], [1 1 1], 'filled', 'v');

            obj.EdgeColor = args.EdgeColor;
            obj.BoxColor = args.BoxColor;
            obj.BoxWidth = args.BoxWidth;
            obj.MedianColor = args.MedianColor;
            if not(isempty(args.DabestViolinColor))
                obj.DabestViolinColor = args.DabestViolinColor;
            else
                obj.DabestViolinColor = obj.ScatterPlot.CData;
            end
            obj.DabestViolinAlpha = args.DabestViolinAlpha;
            obj.ShowData = args.ShowData;
            obj.ShowNotches = args.ShowNotches;
            obj.ShowMean = args.ShowMean;
        end

        function set.EdgeColor(obj, color)
            if ~isempty(obj.DabestViolinPlot)
                obj.DabestViolinPlot.EdgeColor = color;
            end
        end

        function color = get.EdgeColor(obj)
            if ~isempty(obj.DabestViolinPlot)
                color = obj.DabestViolinPlot.EdgeColor;
            end
        end

        function set.MedianColor(obj, color)
            obj.MedianPlot.MarkerFaceColor = color;
            if ~isempty(obj.NotchPlots)
                obj.NotchPlots(1).MarkerFaceColor = color;
                obj.NotchPlots(2).MarkerFaceColor = color;
            end
        end

        function color = get.MedianColor(obj)
            color = obj.MedianPlot.MarkerFaceColor;
        end

        function set.BoxColor(obj, color)
            if ~isempty(obj.BoxPlot)
                obj.BoxPlot.FaceColor = color;
                obj.BoxPlot.EdgeColor = color;
                obj.WhiskerPlot.Color = color;
                obj.MedianPlot.MarkerEdgeColor = color;
                obj.NotchPlots(1).MarkerFaceColor = color;
                obj.NotchPlots(2).MarkerFaceColor = color;
            end
        end

        function color = get.BoxColor(obj)
            if ~isempty(obj.BoxPlot)
                color = obj.BoxPlot.FaceColor;
            end
        end
        
        function set.BoxWidth(obj,width)
            if ~isempty(obj.BoxPlot)
                pos=mean(obj.BoxPlot.XData);
                obj.BoxPlot.XData=pos+[-1,1,1,-1]*width;
            end
        end
        
        function width = get.BoxWidth(obj)
            width=max(obj.BoxPlot.XData)-min(obj.BoxPlot.XData);
        end

        function set.DabestViolinColor(obj, color)
            obj.DabestViolinPlot.FaceColor = color;
            obj.ScatterPlot.MarkerFaceColor = color;
            obj.MeanPlot.Color = color;
        end

        function color = get.DabestViolinColor(obj)
            color = obj.DabestViolinPlot.FaceColor;
        end

        function set.DabestViolinAlpha(obj, alpha)
            obj.ScatterPlot.MarkerFaceAlpha = alpha;
            obj.DabestViolinPlot.FaceAlpha = alpha;
        end

        function alpha = get.DabestViolinAlpha(obj)
            alpha = obj.DabestViolinPlot.FaceAlpha;
        end

        function set.ShowData(obj, yesno)
            if yesno
                obj.ScatterPlot.Visible = 'on';
            else
                obj.ScatterPlot.Visible = 'off';
            end
        end

        function yesno = get.ShowData(obj)
            if ~isempty(obj.ScatterPlot)
                yesno = strcmp(obj.ScatterPlot.Visible, 'on');
            end
        end

        function set.ShowNotches(obj, yesno)
            if ~isempty(obj.NotchPlots)
                if yesno
                    obj.NotchPlots(1).Visible = 'on';
                    obj.NotchPlots(2).Visible = 'on';
                else
                    obj.NotchPlots(1).Visible = 'off';
                    obj.NotchPlots(2).Visible = 'off';
                end
            end
        end

        function yesno = get.ShowNotches(obj)
            if ~isempty(obj.NotchPlots)
                yesno = strcmp(obj.NotchPlots(1).Visible, 'on');
            end
        end

        function set.ShowMean(obj, yesno)
            if ~isempty(obj.MeanPlot)
                if yesno
                    obj.MeanPlot.Visible = 'on';
                else
                    obj.MeanPlot.Visible = 'off';
                end
            end
        end

        function yesno = get.ShowMean(obj)
            if ~isempty(obj.MeanPlot)
                yesno = strcmp(obj.MeanPlot.Visible, 'on');
            end
        end
    end

    methods (Access=private)
        function results = checkInputs(obj, data, pos, trueMedianDiff,varargin)
            isscalarnumber = @(x) (isnumeric(x) & isscalar(x));
            p = inputParser();
            p.addRequired('Data', @isnumeric);
            p.addRequired('Pos', isscalarnumber);
            p.addRequired('TrueMedianDiff', @isnumeric);
            p.addParameter('Width', 0.3, isscalarnumber);
            p.addParameter('Bandwidth', [], isscalarnumber);
            iscolor = @(x) (isnumeric(x) & length(x) == 3);
            p.addParameter('DabestViolinColor', [], iscolor);
            p.addParameter('BoxColor', [0 0 0], iscolor);
            p.addParameter('BoxWidth', 0.01, isscalarnumber);
            p.addParameter('EdgeColor', 'none', iscolor);
            p.addParameter('MedianColor', [0 0 0], iscolor);
            p.addParameter('DabestViolinAlpha', 1, isscalarnumber);
            isscalarlogical = @(x) (islogical(x) & isscalar(x));
            p.addParameter('ShowData', true, isscalarlogical);
            p.addParameter('ShowNotches', false, isscalarlogical);
            p.addParameter('ShowMean', false, isscalarlogical);

            p.parse(data, pos, trueMedianDiff,varargin{:});
            results = p.Results;
        end
    end
end
