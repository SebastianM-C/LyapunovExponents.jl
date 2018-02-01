module LinzSprott99
export linz_sprott_99
using ..ExampleBase: LEDemo, ContinuousExample

"""
Return a [`LEDemo`](@ref) for the simplest piecewise linear
dissipative chaotic flow.

* <http://sprott.physics.wisc.edu/chaos/comchaos.htm>
* S. J. Linz and J. C. Sprott, Phys. Lett. A 259, 240-245 (1999)
"""
function linz_sprott_99(;
        u0=[0.1, 0.1, 0.1],
        tspan=(0.0, 1.0),
        num_attr=10000,
        atol=1e-5, rtol=1e-2,
        kwargs...)
    @inline function phase_dynamics!(du, u, p, t)
        du[1] = u[2]
        du[2] = u[3]
        du[3] = -0.6 * u[3] - u[2] - (u[1] > 0 ? 1 : -1) * u[1] + 1
    end
    @inline @views function tangent_dynamics!(du, u, p, t)
        phase_dynamics!(du[:, 1], u[:, 1], p, t)
        du[1, 2:end] = u[2, 2:end]
        du[2, 2:end] = u[3, 2:end]
        du[3, 2:end] .=
            -0.6 .* u[3, 2:end] .- u[2, 2:end] .-
            (u[1, 1] > 0 ? 1 : -1) .* u[1, 2:end]
    end
    LEDemo(ContinuousExample(
        "Linz & Sprott (1999) Piecewise linear flow",
        phase_dynamics!,
        u0, tspan, num_attr,
        tangent_dynamics!,
        [0.0362, 0, -0.6362],   # known_exponents
        atol, rtol,
    ); kwargs...)
end

end