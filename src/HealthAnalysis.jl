module HealthAnalysis

using Plots
using DataFrames
using XML
using Format
using Dates

export get_data

function get_data(device; correction = false, min_steps = 15000, view_year = year(now()) - 1)

    data = read(
        string(
        @__DIR__,"/..",
        "/data/Export.xml"), Node)

    data = data[3]

    function get_steps(node::Node)

        if "type" in keys(node.attributes)
            if node.attributes["type"] == "HKQuantityTypeIdentifierStepCount"
                return [node.attributes["sourceName"], node.attributes["startDate"], node.attributes["endDate"], node.attributes["value"]]
            else
                return nothing
            end
        else
            return nothing
        end

    end

    step_data = [get_steps(data[i]) for i in 1:length(data)]

    step_data = filter(x -> x !== nothing, step_data)
    step_data = DataFrame(source = [x[1] for x in step_data], start_date = [x[2] for x in step_data], end_date = [x[3] for x in step_data], value = [x[4] for x in step_data])
    
    if correction
        step_data.source = replace.(step_data.source, r"[^a-zA-Z]" => "")
        device = replace(device, r"[^a-zA-Z]" => "")
    end

    # Restrict to apple watch data

    step_data = filter(row -> row.source == device, step_data)

    if length(step_data.value) == 0
        @warn "No data for device: "*device
        return nothing
    end

    step_data.date = Date.(SubString.(step_data.start_date, 1, 10))
    step_data.value = parse.(Int64, step_data.value)

    step_agg = combine(
        groupby(step_data[in(Date(view_year, 1, 1):Date(view_year, 12, 31)).(step_data.date),:], :date),
        :value => sum => :value
    )

    step_plot = plot(step_agg.date, step_agg.value, legend = false, title = "Schritte pro Tag \n Gemessen über Apple Watch \n Anzahl Tage mit mehr als "*replace(format(min_steps, commas = true), "," => ".")*" Schritten: "*string(length(step_agg.value[step_agg.value .>= min_steps])), titlefontsize = 10, xlabel = "Datum", ylabel = "Anzahl Schritte", ylim = [0,35000], seriestype = :bar, seriescolor = RGB(30/255, 63/255, 114/255), linecolor = RGB(30/255, 63/255, 114/255))
    plot!(minimum(step_agg.date):maximum(step_agg.date), repeat([min_steps], length(minimum(step_agg.date):maximum(step_agg.date))), linecolor = RGB(1, 102/255,0))
    
    # Get egym data

    function search_activity(node::Node)

        for i in 1:length(node)

            if "type" in keys(node[i].attributes)
                if node[i].attributes["type"] == "HKQuantityTypeIdentifierActiveEnergyBurned"
                    return node[i].attributes["sum"]
                end
            end
        end

        return nothing

    end

    function get_egym(node::Node)

        if "workoutActivityType" in keys(node.attributes)
            if node.attributes["workoutActivityType"] == "HKWorkoutActivityTypeOther"
                return [node.attributes["sourceName"], node.attributes["startDate"], node.attributes["endDate"], search_activity(node), node.attributes["duration"]]
            else
                return nothing
            end
        else
            return nothing
        end

    end

    egym_data = [get_egym(data[i]) for i in 1:length(data)]

    egym_data = filter(x -> x !== nothing, egym_data)
    egym_data = DataFrame(source = [x[1] for x in egym_data], start_date = [x[2] for x in egym_data], end_date = [x[3] for x in egym_data], calories = [x[4] for x in egym_data], time = [x[5] for x in egym_data])
    egym_data.source = replace.(egym_data.source, r"[^a-zA-Z]" => "")

    # Restrict to egym

    egym_data = filter(row -> row.source == "EGYMFitness", egym_data)

    egym_data.date = Date.(SubString.(egym_data.start_date, 1, 10))
    egym_data.calories = parse.(Int64, egym_data.calories)

    egym_agg = combine(
        groupby(egym_data[in(Date(view_year, 1, 1):Date(view_year, 12, 31)).(egym_data.date),:], :date),
        df -> DataFrame(calories = sum(df.calories), count = size(df, 1))
    )

    egym_cal_plot = plot(egym_agg.date, egym_agg.calories, legend = false, title = "Aktivitäten im eGym", titlefontsize = 10, xlabel = "Datum", ylabel = "Kalorien (in kcal)", ylim = [0,1500], seriestype = :bar, seriescolor = RGB(30/255, 63/255, 114/255), linecolor = RGB(30/255, 63/255, 114/255))
    egym_count_plot = plot(egym_agg.date, egym_agg.count, legend = false, title = "Aktivitäten im eGym\nGesamt: "*string(sum(egym_agg.count)), titlefontsize = 10, xlabel = "Datum", ylabel = "Anzahl Aktivitäten", ylim = [0,2], seriestype = :bar, seriescolor = RGB(30/255, 63/255, 114/255), linecolor = RGB(30/255, 63/255, 114/255))
    
    plot!(minimum(step_agg.date):maximum(step_agg.date), repeat([min_steps], length(minimum(step_agg.date):maximum(step_agg.date))), linecolor = RGB(1, 102/255,0))

    return (steps = step_plot, egym_cals = egym_cal_plot, egym_count = egym_count_plot)

end

end # module HealthAnalysis
