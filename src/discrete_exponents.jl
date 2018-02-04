mutable struct DiscreteIterator
    prob
    u0
    u1

    function DiscreteIterator(prob)
        u0 = copy(prob.u0)
        u1 = similar(prob.u0)
        new(prob, u0, u1)
    end
end

get_integrator(prob::DiscreteProblem) = DiscreteIterator(prob)

function keepgoing!(diter::DiscreteIterator, u0=diter.u0)
    tmin, tmax = diter.prob.tspan
    f = diter.prob.f
    p = diter.prob.p
    u1 = diter.u1
    for t in tmin:tmax
        f(u1, u0, p, t)
        u0, u1 = u1, u0
    end
    diter.u0 = u0
    diter.u1 = u1
end

const DiscreteLEProblem = LEProblem{DiscreteProblem}

"""
    DiscreteLEProblem(phase_dynamics!, u0, tspan [, p [, num_attr]];
                      <keyword arguments>)

This is a short-hand notation for:

```julia
LEProblem(DiscreteProblem(...) [, num_attr]; ...)
```

For the list of usable keyword arguments, see [`LEProblem`](@ref).
"""
DiscreteLEProblem(phase_dynamics!, u0, tspan, p=nothing,
                  args...; kwargs...) =
    DiscreteLEProblem(DiscreteProblem(phase_dynamics!, u0, tspan, p),
                      args...; kwargs...)

const DiscreteRelaxer = Relaxer{<: DiscreteLEProblem}

last_state(relaxer::DiscreteRelaxer) = relaxer.integrator.u0

init_phase_state(integrator::DiscreteIterator) = integrator.u0[:, 1]
init_tangent_state(integrator::DiscreteIterator) = integrator.u0[:, 2:end]
const DiscreteLESolver = AbstractLESolver{<: DiscreteIterator}

current_state(integrator::DiscreteIterator) = integrator.u0

@inline function current_state(solver::DiscreteLESolver)
    solver.integrator.u0
end

function t_chunk(solver::DiscreteLESolver)
    tspan = solver.integrator.prob.tspan
    tspan[2] - tspan[1] + 1
end
