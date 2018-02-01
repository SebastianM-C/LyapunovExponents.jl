module VanDerPol
export van_der_pol
using ..ExampleBase: LEDemo, ContinuousExample

"""
Return a [`LEDemo`](@ref) for the van der Pol oscillator with
periodic forcing.

`.known_exponents` are extracted from Figure 6 of Geist, Parlitz &
Lauterborn (1990).

* <http://scholarpedia.org/article/Van_der_Pol_oscillator>
* <https://en.wikipedia.org/wiki/Van_der_Pol_oscillator>
* van der Pol and van der Mark. “Frequency Demultiplication.”
  Nature 120, no. 3019 (September 1927): 363.
  <https://doi.org/10.1038/120363a0>.
* Parlitz, Ulrich, and Werner Lauterborn. “Period-Doubling Cascades and
  Devil’s Staircases of the Driven van Der Pol Oscillator.”
  Physical Review A 36, no. 3 (August 1, 1987): 1428–34.
  <https://doi.org/10.1103/PhysRevA.36.1428>.
  (Figure 10a)
* Geist, K., Parlitz, U., & Lauterborn, W. (1990).
  Comparison of Different Methods for Computing Lyapunov Exponents.
  Progress of Theoretical Physics, 83, 875–893.
  <https://doi.org/10.1143/PTP.83.875>.
  (Figure 6)
"""
function van_der_pol(;
        u0=[0.1, 0.1],
        t0=0.0, chunk_periods=1,
        ω=2.466, tspan=(t0, t0 + chunk_periods * 2 * π / ω),
        num_attr=200,
        atol=0, rtol=1e-1,
        kwargs...)
    # Note that with larger num_attr (e.g., 10000), the last Lyapunov
    # exponents negatively overshoots what Geist, Parlitz & Lauterborn
    # (1990) reported.  num_attr=100 is required for test to pass.
    @inline function phase_dynamics!(du, u, p, t)
        du[1] = u[2]
        du[2] = -u[1] - 5.0 * (u[1]^2 - 1) * u[2] + 5.0 * cos(ω * t)
    end
    @inline @views function tangent_dynamics!(du, u, p, t)
        phase_dynamics!(du[:, 1], u[:, 1], p, t)
        du[1, 2:end] .= u[2, 2:end]
        du[2, 2:end] .= -u[1, 2:end] .-
            5.0 * (u[1, 1]^2 - 1) .* u[2, 2:end] .-
            5.0 * 2.0 * u[1, 1] * u[2, 1] .* u[1, 2:end]
    end
    LEDemo(ContinuousExample(
        "van der Pol & van der Mark (1927)",
        phase_dynamics!,
        u0, tspan, num_attr,
        tangent_dynamics!,
        [0.085, -6.7],   # known_exponents
        atol, rtol,
    ); kwargs...)
end

end