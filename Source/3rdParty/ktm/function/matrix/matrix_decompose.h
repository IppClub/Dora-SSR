//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_MATRIX_DECOMPOSE_H_
#define _KTM_MATRIX_DECOMPOSE_H_

#include "../../setup.h"
#include "../../type/basic.h"
#include "../../traits/type_traits_math.h"
#include "../../traits/type_matrix_component.h"
#include "../common.h"
#include "../compare.h"
#include "../geometric.h"
#include "matrix_algebra.h"

namespace ktm
{

#define KTM_MATRIX_DECOMPOSE_ITERATION_MAX 120

template <class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, reduce_component<M>>
reduce_hessenberg(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_v<M>;
    using T = mat_traits_base_t<M>;

    // reduce matrix to hessenberg by householder transformation
    M trans = M::from_eye(), a { m };

    for (int i = 0; i < N - 2; ++i)
    {
        T v_start = i + 1;
        T length = zero<T>;
        for (int j = v_start; j < N; ++j)
        {
            ktm_op_smadd(length, a[i][j], a[i][j]);
        }
        if (equal(length, abs(a[i][v_start])))
            continue;
        length = std::copysign(sqrt(length), -a[i][v_start]);

        T recip_h = recip(ktm_op_madd(-length * a[i][v_start], length, length));
        a[i][v_start] = (a[i][v_start] - length);

        for (int k = i + 1; k < N; ++k)
        {
            T ta = zero<T>;
            for (int j = v_start; j < N; ++j)
            {
                ktm_op_smadd(ta, a[i][j], a[k][j]);
            }
            ta *= recip_h;
            for (int j = v_start; j < N; ++j)
            {
                ktm_op_smadd(a[k][j], -ta, a[i][j]);
            }
        }
        for (int k = 0; k < N; ++k)
        {
            T ta = zero<T>;
            T tt = zero<T>;
            for (int j = v_start; j < N; ++j)
            {
                ktm_op_smadd(ta, a[i][j], a[j][k]);
                ktm_op_smadd(tt, a[i][j], trans[j][k]);
            }
            ta *= recip_h;
            tt *= recip_h;
            for (int j = v_start; j < N; ++j)
            {
                ktm_op_smadd(a[j][k], -ta, a[i][j]);
                ktm_op_smadd(trans[j][k], -tt, a[i][j]);
            }
        }

        a[i][v_start] = length;
        for (int j = v_start + 1; j < N; ++j)
        {
            a[i][j] = zero<T>;
        }
    }
    return { trans, a };
}

template <class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, reduce_component<M>>
reduce_tridiagonal(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_v<M>;
    using T = mat_traits_base_t<M>;

    // reduce matrix to tridiagonal by householder transformation(matrix must be symmetric matrix)
    M trans = M::from_eye(), a { m };

    for (int i = 0; i < N - 2; ++i)
    {
        T v_start = i + 1;
        T length = zero<T>;
        for (int j = v_start; j < N; ++j)
        {
            ktm_op_smadd(length, a[i][j], a[i][j]);
        }
        if (equal(length, abs(a[i][v_start])))
            continue;
        length = std::copysign(sqrt(length), -a[i][v_start]);

        vec<N, T> u {};
        u[v_start] = a[i][v_start] - length;
        for (int j = v_start + 1; j < N; ++j)
        {
            u[j] = a[i][j];
        }

        T recip_h = recip(ktm_op_madd(-length * a[i][v_start], length, length));
        vec<N, T> q {};
        for (int j = v_start; j < N; ++j)
        {
            ktm_op_smadd(q, a[j], u[j]);
        }
        q *= recip_h;

        T dot_qu = zero<T>;
        for (int j = v_start; j < N; ++j)
        {
            ktm_op_smadd(dot_qu, q[j], u[j]);
        }
        ktm_op_smadd(q, dot_qu * static_cast<T>(-0.5) * recip_h, vec<N, T>(u));

        a[i][v_start] = length;
        a[v_start][i] = length;
        for (int j = v_start + 1; j < N; ++j)
        {
            a[i][j] = zero<T>;
            a[j][i] = zero<T>;
        }
        for (int k = i + 1; k < N; ++k)
        {
            a[k][k] -= ktm_op_madd(u[k] * q[k], q[k], u[k]);
            for (int j = k + 1; j < N; ++j)
            {
                a[k][j] -= ktm_op_madd(u[j] * q[k], q[j], u[k]);
                a[j][k] = a[k][j];
            }
        }

        for (int k = 1; k < N; ++k)
        {
            T tt = zero<T>;
            for (int j = v_start; j < N; ++j)
            {
                ktm_op_smadd(tt, u[j], trans[j][k]);
            }
            tt *= recip_h;
            for (int j = v_start; j < N; ++j)
            {
                ktm_op_smadd(trans[j][k], -tt, u[j]);
            }
        }
    }
    return { trans, a };
}

template <class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, lu_component<M>>
decompose_lu_doolittle(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_v<M>;
    using T = mat_traits_base_t<M>;

    // doolittle for matrix lu decomposition, row transfrom
    M l = M::from_eye(), u { m };

    for (int i = 0; i < N - 1; ++i)
    {
        T recip_uii = recip(u[i][i]);
        for (int j = i + 1; j < N; ++j)
        {
            l[i][j] = u[i][j] * recip_uii;
            u[i][j] = zero<T>;
            for (int k = i + 1; k < N; ++k)
            {
                ktm_op_smadd(u[k][j], -l[i][j], u[k][i]);
            }
        }
    }

    return { l, u };
}

template <class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, lu_component<M>>
decompose_lu_crout(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_v<M>;
    using T = mat_traits_base_t<M>;

    // crout for matrix lu decomposition, col transform
    M l { m }, u = M::from_eye();

    for (int i = 0; i < N - 1; ++i)
    {
        T recip_lii = recip(l[i][i]);
        for (int j = i + 1; j < N; ++j)
        {
            u[j][i] = l[j][i] * recip_lii;
            l[j][i] = zero<T>;
            for (int k = i + 1; k < N; ++k)
            {
                ktm_op_smadd(l[j][k], -l[i][k], u[j][i]);
            }
        }
    }

    return { l, u };
}

template <class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, lu_component<M>>
decompose_lu_cholesky(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_v<M>;
    using T = mat_traits_base_t<M>;

    // cholesky for matrix lu decomposition(matrix must be positive definite matrix)
    M u {};

    for (int i = 0; i < N; ++i)
    {
        for (int j = 0; j <= i; ++j)
        {
            T mij = m[i][j];
            for (int k = 0; k < j; ++k)
            {
                ktm_op_smadd(mij, -u[i][k], u[j][k]);
            }

            if (i == j)
            {
                u[i][j] = sqrt(mij);
            }
            else
            {
                u[i][j] = mij * recip(u[j][j]);
            }
        }
    }

    return { transpose(u), u };
}

template <class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, qr_component<M>>
decompose_qr_householder(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_v<M>;
    using T = mat_traits_base_t<M>;

    // householder transformation for matrix qr decomposition
    M q = M::from_eye(), r { m };

    for (int i = 0; i < N - 1; ++i)
    {
        T length = zero<T>;
        for (int j = i; j < N; ++j)
        {
            ktm_op_smadd(length, r[i][j], r[i][j]);
        }
        if (equal(length, abs(r[i][i])))
            continue;
        length = std::copysign(sqrt(length), -r[i][i]);

        T recip_h = recip(ktm_op_madd(-length * r[i][i], length, length));
        r[i][i] = (r[i][i] - length);

        for (int k = 0; k <= i; ++k)
        {
            T tq = zero<T>;
            for (int j = i; j < N; ++j)
            {
                ktm_op_smadd(tq, r[i][j], q[j][k]);
            }
            tq *= recip_h;
            for (int j = i; j < N; ++j)
            {
                ktm_op_smadd(q[j][k], -tq, r[i][j]);
            }
        }
        for (int k = i + 1; k < N; ++k)
        {
            T tq = zero<T>;
            T tr = zero<T>;
            for (int j = i; j < N; ++j)
            {
                ktm_op_smadd(tq, r[i][j], q[j][k]);
                ktm_op_smadd(tr, r[i][j], r[k][j]);
            }
            tq *= recip_h;
            tr *= recip_h;
            for (int j = i; j < N; ++j)
            {
                ktm_op_smadd(q[j][k], -tq, r[i][j]);
                ktm_op_smadd(r[k][j], -tr, r[i][j]);
            }
        }

        r[i][i] = length;
        for (int j = i + 1; j < N; ++j)
        {
            r[i][j] = zero<T>;
        }
    }
    return { q, r };
}

template <class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, qr_component<M>>
decompose_qr_givens(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_v<M>;
    using T = mat_traits_base_t<M>;

    // givens rotation for matrix qr decomposition
    M q = M::from_eye(), r { m };

    for (int i = 0; i < N - 1; ++i)
    {
        for (int j = N - 1; j > i; --j)
        {
            if (!equal_zero(r[i][j]))
            {
                vec<2, T> cos_sin = normalize(vec<2, T>(r[i][j - 1], r[i][j]));
                for (int k = 0; k < N; ++k)
                {
                    T tmp = r[k][j - 1];
                    r[k][j - 1] = ktm_op_madd(cos_sin[0] * tmp, cos_sin[1], r[k][j]);
                    r[k][j] = ktm_op_madd(cos_sin[1] * -tmp, cos_sin[0], r[k][j]);

                    tmp = q[j - 1][k];
                    q[j - 1][k] = ktm_op_madd(cos_sin[0] * tmp, cos_sin[1], q[j][k]);
                    q[j][k] = ktm_op_madd(cos_sin[1] * -tmp, cos_sin[0], q[j][k]);
                }
            }
        }
    }
    return { q, r };
}

template <class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, qr_component<M>>
decompose_qr_schmitd(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_v<M>;
    using T = mat_traits_base_t<M>;

    // gram-schmidt orthogonalization for matrix qr decomposition
    M q {}, r {}, a { m };

    for (int i = 0; i < N; ++i)
    {
        r[i][i] = length(a[i]);
        q[i] = a[i] * recip(r[i][i]);

        for (int j = i + 1; j < N; ++j)
        {
            r[j][i] += dot(a[j], q[i]);
            ktm_op_smadd(a[j], -r[j][i], q[i]);
        }
    }
    return { q, r };
}

template <class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, qr_component<M>>
decompose_qr_on_hessenberg(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_v<M>;
    using T = mat_traits_base_t<M>;

    // householder transformation for matrix qr decomposition(matrix must be hessenberg matrix)
    M q = M::from_eye(), r { m };

    for (int i = 0; i < N - 1; ++i)
    {
        T length = ktm_op_madd(r[i][i] * r[i][i], r[i][i + 1], r[i][i + 1]);
        if (equal(length, abs(r[i][i])))
            continue;
        length = std::copysign(sqrt(length), -r[i][i]);

        T recip_h = recip(ktm_op_madd(-length * r[i][i], length, length));
        r[i][i] = (r[i][i] - length);

        for (int k = 0; k <= i + 1; ++k)
        {
            T tq = recip_h * ktm_op_madd(r[i][i] * q[i][k], r[i][i + 1], q[i + 1][k]);
            ktm_op_smadd(q[i][k], -tq, r[i][i]);
            ktm_op_smadd(q[i + 1][k], -tq, r[i][i + 1]);
        }
        for (int k = i + 1; k < N; ++k)
        {
            T tr = recip_h * ktm_op_madd(r[i][i] * r[k][i], r[i][i + 1], r[k][i + 1]);
            ktm_op_smadd(r[k][i], -tr, r[i][i]);
            ktm_op_smadd(r[k][i + 1], -tr, r[i][i + 1]);
        }

        r[i][i] = length;
        r[i][i + 1] = zero<T>;
    }
    return { q, r };
}

template <class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, qr_component<M>>
decompose_qr_on_tridiagonal(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_v<M>;
    using T = mat_traits_base_t<M>;

    // givens rotation for matrix qr decomposition(matrix must be tridiagonal matrix)
    M q = M::from_eye(), r { m };

    for (int i = 0; i < N - 1; ++i)
    {
        if (!equal_zero(r[i][i + 1]))
        {
            vec<2, T> cos_sin = normalize(vec<2, T>(r[i][i], r[i][i + 1]));
            for (int k = i; k < N && k < i + 3; ++k)
            {
                T tmp = r[k][i];
                r[k][i] = ktm_op_madd(cos_sin[0] * tmp, cos_sin[1], r[k][i + 1]);
                r[k][i + 1] = ktm_op_madd(cos_sin[1] * -tmp, cos_sin[0], r[k][i + 1]);
            }
            for (int k = 0; k <= i + 1; ++k)
            {
                T tmp = q[i][k];
                q[i][k] = ktm_op_madd(cos_sin[0] * tmp, cos_sin[1], q[i + 1][k]);
                q[i + 1][k] = ktm_op_madd(cos_sin[1] * -tmp, cos_sin[0], q[i + 1][k]);
            }
        }
    }
    return { q, r };
}

template <class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, edv_component<M>>
decompose_edv_shiftqr(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_v<M>;
    using T = mat_traits_base_t<M>;

    // qr iteration for calc matrix eigenvectors and eigenvalues(matrix must be symmetric matrix)
    reduce_component<M> tridiagonal = reduce_tridiagonal(m);
    M a { tridiagonal.get_reduce() }, eigen_vec = M::from_eye();
    mat_traits_col_t<M> eigen_value;
    int step = N - 1;

    for (int it = 0; it < KTM_MATRIX_DECOMPOSE_ITERATION_MAX; ++it)
    {
        T delta = (a[step - 1][step - 1] - a[step][step]) * static_cast<T>(0.5);
        T diff = sqrt(ktm_op_madd(delta * delta, a[step][step - 1], a[step][step - 1]));
        T step_value = a[step][step] + delta - std::copysign(diff, delta);
        for (int i = 0; i < N; ++i)
        {
            a[i][i] -= step_value;
        }
        qr_component<M> qr = decompose_qr_on_tridiagonal(a);
        a = qr.get_r() * qr.get_q();
        for (int i = 0; i < N; ++i)
        {
            a[i][i] += step_value;
        }
        eigen_vec = eigen_vec * qr.get_q();
        eigen_value = diagonal(a);
        if (equal_zero(a[step - 1][step]))
        {
            if (step > 1)
                --step;
            else
                break;
        }
    }
    return { tridiagonal.get_transform() * eigen_vec, eigen_value };
}

template <class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, edv_component<M>>
decompose_edv_jacobi(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_v<M>;
    using T = mat_traits_base_t<M>;

    // jacobi iteration for matrix eigenvectors and eigenvalues(matrix must be symmetric matrix)
    M a { m }, eigen_vec = M::from_eye();
    mat_traits_col_t<M> eigen_value;

    for (int it = 0; it < KTM_MATRIX_DECOMPOSE_ITERATION_MAX; ++it)
    {
        // find the maximum element on a non diagonal line
        int col = 0, row = 1;
        T nd_max = a[0][1];
        for (int i = 0; i < N; ++i)
        {
            for (int j = i + 1; j < N; ++j)
            {
                T nd_elem = abs(a[i][j]);
                if (nd_elem > nd_max)
                {
                    col = i;
                    row = j;
                    nd_max = nd_elem;
                }
            }
        }

        if (equal_zero(nd_max))
            break;

        T acc = a[col][col];
        T arr = a[row][row];
        T acr = a[col][row];

        // calc rotation angles
        T sin_theta, cos_theta, sin_two_theta, cos_two_theta;

        if (equal(arr, acc))
        {
            if (acr < 0)
            {
                sin_theta = -rsqrt_tow<T>;
                cos_theta = rsqrt_tow<T>;
                sin_two_theta = -one<T>;
                cos_two_theta = zero<T>;
            }
            else
            {
                sin_theta = rsqrt_tow<T>;
                cos_theta = rsqrt_tow<T>;
                sin_two_theta = one<T>;
                cos_two_theta = zero<T>;
            }
        }
        else
        {
            T theta = static_cast<T>(0.5) * atan2(static_cast<T>(2) * acr, acc - arr);
            sin_theta = sin(theta);
            cos_theta = cos(theta);
            sin_two_theta = static_cast<T>(2) * sin_theta * cos_theta;
            cos_two_theta = ktm_op_madd(-sin_theta * sin_theta, cos_theta, cos_theta);
        }

        T sin_theta_square = pow2(sin_theta);
        T cos_theta_square = pow2(cos_theta);
        a[col][col] = ktm_op_madd(ktm_op_madd(acr * sin_two_theta, arr, sin_theta_square), acc, cos_theta_square);
        a[row][row] = ktm_op_madd(ktm_op_madd(-acr * sin_two_theta, arr, cos_theta_square), acc, sin_theta_square);
        a[col][row] = ktm_op_madd(acr * cos_two_theta, static_cast<T>(0.5) * (arr - acc), sin_two_theta);
        a[row][col] = a[col][row];

        // givens rotate
        for (int i = 0; i < N; ++i)
        {
            if ((i != col) && (i != row))
            {
                T aci = a[col][i];
                T ari = a[row][i];

                a[col][i] = ktm_op_madd(sin_theta * ari, cos_theta, aci);
                a[row][i] = ktm_op_madd(-sin_theta * aci, cos_theta, ari);
                a[i][col] = a[col][i];
                a[i][row] = a[row][i];
            }
        }

        for (int i = 0; i < N; ++i)
        {
            T eci = eigen_vec[col][i];
            T eri = eigen_vec[row][i];

            eigen_vec[col][i] = ktm_op_madd(sin_theta * eri, cos_theta, eci);
            eigen_vec[row][i] = ktm_op_madd(-sin_theta * eci, cos_theta, eri);
        }
    }
    eigen_value = diagonal(a);
    return { eigen_vec, eigen_value };
}

template <class M>
KTM_NOINLINE std::enable_if_t<is_floating_point_base_v<M>, svd_component<M>> decompose_svd(const M& m) noexcept
{
    using u_type = typename svd_component<M>::u_type;
    using s_type = typename svd_component<M>::s_type;
    using vt_type = typename svd_component<M>::vt_type;
    constexpr size_t row_n = mat_traits_row_v<M>;
    constexpr size_t col_n = mat_traits_col_v<M>;

    // calc matrix svd decomposition(using decompose_edv_jacobi to decompose matrix eigenvectors and eigenvalues)
    if constexpr (row_n >= col_n)
    {
        // if row_n >= col_n, first calc v matrix
        edv_component<vt_type> ata_eigen = decompose_edv_jacobi(transpose(m) * m);
        s_type s, inv_s;
        if constexpr (row_n == col_n)
        {
            s = sqrt(abs(ata_eigen.get_value()));
            inv_s = recip(s);
        }
        else
        {
            for (int i = 0; i < col_n; ++i)
            {
                s[i] = sqrt(abs(ata_eigen.get_value()[i]));
                inv_s[i] = recip(s[i]);
            }
        }
        mat_traits_tp_t<M> inv_s_matrix {};
        for (int i = 0; i < col_n; ++i)
        {
            inv_s_matrix[i][i] = inv_s[i];
        }
        vt_type& v = ata_eigen.get_vector();
        u_type u = m * v * inv_s_matrix;
        return { u, s, transpose(v) };
    }
    else
    {
        // if row_n < col_n, first calc u matrix
        edv_component<u_type> aat_eigen = decompose_edv_jacobi(m * transpose(m));
        s_type s, inv_s;
        for (int i = 0; i < row_n; ++i)
        {
            s[i] = sqrt(abs(aat_eigen.get_value()[i]));
            inv_s[i] = recip(s[i]);
        }
        mat_traits_tp_t<M> inv_s_matrix {};
        for (int i = 0; i < row_n; ++i)
        {
            inv_s_matrix[i][i] = inv_s[i];
        }
        u_type& u = aat_eigen.get_vector();
        vt_type vt = inv_s_matrix * transpose(u) * m;
        return { u, s, vt };
    }
}

template <class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, affine_component<M>>
decompose_affine(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_v<M>;
    using T = mat_traits_base_t<M>;

    // calc matrix affine decomposition(translation * rotation * shear * scale)
    if constexpr (N == 2)
    {
        M translate_matrix = M::from_eye();
        translate_matrix[1][0] = m[1][0];
        M scale_matrix = M::from_eye();
        scale_matrix[0][0] = m[0][0];
        return { translate_matrix, M::from_eye(), M::from_eye(), scale_matrix };
    }
    else
    {
        using AffM = mat<N - 1, N - 1, T>;
        using AffV = vec<N - 1, T>;
        constexpr auto m_to_affm_lambda = [N](const M& in_m, AffM& out_affm) -> void
        {
            for (int i = 0; i < N - 1; ++i)
                std::copy(in_m[i].begin(), in_m[i].end() - 1, out_affm[i].begin());
        };
        constexpr auto affm_to_m_lambda = [N](const AffM& in_affm, M& out_m) -> void
        {
            for (int i = 0; i < N - 1; ++i)
            {
                std::copy(in_affm[i].begin(), in_affm[i].end(), out_m[i].begin());
                out_m[i][N - 1] = zero<T>;
            }
            std::fill(out_m[N - 1].begin(), out_m[N - 1].end(), zero<T>);
            out_m[N - 1][N - 1] = one<T>;
        };

        AffM affine_matrix;
        m_to_affm_lambda(m, affine_matrix);
        qr_component<AffM> affine_qr = decompose_qr_givens(affine_matrix);
        AffM& affine_rotate_ref = affine_qr.get_q();
        AffM& affine_upper_ref = affine_qr.get_r();
        AffV affine_diag_vec = diagonal(affine_upper_ref);
        mat_traits_col_t<M> diag_vec;
        for (int i = 0; i < N - 1; ++i)
        {
            diag_vec[i] = affine_diag_vec[i];
            affine_upper_ref[i] *= recip(diag_vec[i]);
        }
        diag_vec[N - 1] = one<T>;

        M translate_matrix = M::from_eye();
        translate_matrix[N - 1] = m[N - 1];
        M rotate_matrix;
        affm_to_m_lambda(affine_rotate_ref, rotate_matrix);
        M shear_matrix;
        affm_to_m_lambda(affine_upper_ref, shear_matrix);
        M scale_matrix = M::from_diag(diag_vec);

        return { translate_matrix, rotate_matrix, shear_matrix, scale_matrix };
    }
}

#undef KTM_MATRIX_DECOMPOSE_ITERATION_MAX

} // namespace ktm

#endif