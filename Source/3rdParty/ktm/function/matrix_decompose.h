//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_MATRIX_DECOMPOSE_H_
#define _KTM_MATRIX_DECOMPOSE_H_

#include <cstring>
#include "../setup.h"
#include "../type/basic.h"
#include "../traits/type_traits_math.h"
#include "../traits/type_matrix_component.h"
#include "exponential.h"
#include "trigonometric.h"
#include "compare.h"
#include "geometric.h"
#include "matrix.h"

#define KTM_MATRIX_DECOMPOSE_ITERATION_MAX 100

namespace ktm
{

template<class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, lu_component<M>> decompose_lu_doolittle(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_n<M>;
    using T = mat_traits_base_t<M>;

    // doolittle for matrix lu decomposition, row transfrom
    M l = M::from_eye(), u { m };

    for(int i = 0; i < N - 1; ++i)
    {
        T r_uii = recip(u[i][i]);
        for(int j = i + 1; j < N; ++j)
        {
            l[i][j] = u[i][j] * r_uii;
            u[i][j] = zero<T>;
            for(int k = i + 1; k < N; ++k)
            {
                u[k][j] -= l[i][j] * u[k][i];
            }
        }
    }

    return { l, u };
}

template<class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, lu_component<M>> decompose_lu_crout(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_n<M>;
    using T = mat_traits_base_t<M>;

    // crout for matrix lu decomposition, col transform
    M l = { m }, u = M::from_eye();

    for(int i = 0; i < N - 1; ++i)
    {
        T r_lii = recip(l[i][i]);
        for(int j = i + 1; j < N; ++j)
        {
            u[j][i] = l[j][i] * r_lii;
            l[j][i] = zero<T>;
            for(int k = i + 1; k < N; ++k)
            {
                l[j][k] -= l[i][k] * u[j][i];
            }
        }
    }
    
    return { l, u };
}

template<class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, lu_component<M>> decompose_lu_cholesky(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_n<M>;
    using T = mat_traits_base_t<M>;

    // cholesky for matrix lu decomposition(matrix must be positive definite matrix)
    M u = { };

    for(int i = 0; i < N; ++i)
    {
        for(int j = 0; j <= i; ++j)
        {
            T mij = m[i][j];
            for(int k = 0; k < j; ++k)
            {
                mij -= u[i][k] * u[j][k];
            }

            if(i == j)
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

template<class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, qr_component<M>> decompose_qr_householder(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_n<M>;
    using T = mat_traits_base_t<M>;

    // householder transformation for matrix qr decomposition
    M q = M::from_eye(), r { m };

    for(int i = 0; i < N; ++i)
    {
        T alpha = zero<T>;
        for(int j = i; j < N; ++j)
        {
            alpha += r[i][j] * r[i][j];
        }
        alpha = std::copysign(sqrt(alpha), -r[i][i]);

        if(!equal(alpha, r[i][i]))
        {
            T r_rho = rsqrt(static_cast<T>(2) * alpha * (alpha - r[i][i]));
            r[i][i] = (r[i][i] - alpha) * r_rho;
            for(int j = i + 1; j < N; ++j)
            {
                r[i][j] *= r_rho;
            }
        }
        
        for(int k = 0; k < N; ++k)
        {
            T tq = zero<T>;
            T tr = zero<T>;
            for(int j = i; j < N; ++j)
            {
                tq += r[i][j] * q[k][j];
                tr += r[i][j] * r[k][j];
            }
            for(int j = i; j < N; ++j)
            {
                q[k][j] -= static_cast<T>(2) * tq * r[i][j];
                r[k][j] -= static_cast<T>(2) * tr * r[i][j];
            }
        }
        r[i][i] = alpha;
        for(int j = i + 1; j < N; ++j)
        {
            r[i][j] = zero<T>;
        }
    }
    return { transpose(q), r };
}

template<class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, qr_component<M>> decompose_qr_givens(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_n<M>;
    using T = mat_traits_base_t<M>;

    // givens rotation for matrix qr decomposition
    M q = M::from_eye(), r { m };

    for(int i = 0; i < N; ++i) 
    {
        for(int j = N - 1; j > i; --j) 
        {
            if(!equal_zero(r[i][j]))
            {
                vec<2, T> cos_sin = normalize(vec<2, T>(r[i][j - 1], r[i][j]));       
                for(int k = 0; k < N; ++k) 
                {
                    T tmp = r[k][j - 1];
                    r[k][j - 1] = cos_sin[0] * tmp + cos_sin[1] * r[k][j];
                    r[k][j] = cos_sin[0] * r[k][j] - cos_sin[1] * tmp;

                    tmp = q[j - 1][k];
                    q[j - 1][k] = cos_sin[0] * tmp + cos_sin[1] * q[j][k];
                    q[j][k] = cos_sin[0] * q[j][k] - cos_sin[1] * tmp;
                }
            }
        }
    }
    return { q, r };
}

template<class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, qr_component<M>> decompose_qr_schmitd(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_n<M>;
    using T = mat_traits_base_t<M>;

    // gram-schmidt orthogonalization for matrix qr decomposition
    M q { }, r { }, a { m };

    for(int i = 0; i < N; ++i)
	{
		r[i][i] = length(a[i]);
        q[i] = a[i] * recip(r[i][i]);

		for(int j = i + 1; j < N; ++j)
		{
            r[j][i] += dot(a[j], q[i]);
			a[j] -= r[j][i] * q[i];
		}
	}
    return { q, r };
}

template<class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, eigen_component<M>> decompose_eigen_qrit(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_n<M>;
    using T = mat_traits_base_t<M>;

    // qr iteration for calc matrix eigenvectors and eigenvalues
    M a { m }, eigen_vec = M::from_eye();
    mat_traits_col_t<M> eigen_value, last_eigen_value = diagonal(a), one_vec;
    one_vec.fill(one<T>);

    for(int it = 0; it < KTM_MATRIX_DECOMPOSE_ITERATION_MAX; ++it) 
    {
        M shift_i = M::from_diag(one_vec * a[N - 1][N - 1]);
        qr_component<M> qr = decompose_qr_householder(a - shift_i);
        a = qr.get_r() * qr.get_q() + shift_i;
        eigen_vec = eigen_vec * qr.get_q();
        eigen_value = diagonal(a);
        if(equal(eigen_value, last_eigen_value))
            break;
        last_eigen_value = eigen_value;
    }
    return { eigen_value, eigen_vec };
}

template<class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, eigen_component<M>> decompose_eigen_jacobi(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_n<M>;
    using T = mat_traits_base_t<M>;

    // jacobi iteration for matrix eigenvectors and eigenvalues(matrix must be symmetric matrix)
    M a { m }, eigen_vec = M::from_eye();
    mat_traits_col_t<M> eigen_value;

    for(int it = 0; it < KTM_MATRIX_DECOMPOSE_ITERATION_MAX; ++it)
    {
        // find the maximum element on a non diagonal line
        int col = 0, row = 1;
        T nd_max = a[0][1];
        for(int i = 0; i < N; ++i)
        {
            for(int j = i + 1; j < N; ++j)
            {
                T nd_elem = abs(a[i][j]);
                if(nd_elem > nd_max)
                {
                    col = i;
                    row = j;
                    nd_max = nd_elem;
                }
            }
        }
        
        if(equal_zero(nd_max))
            break;
        
        T acc = a[col][col];
        T arr = a[row][row];
        T acr = a[col][row];
        
        // calc rotation angles
        T sin_theta, cos_theta, sin_two_theta, cos_two_theta;

        if(equal(arr, acc))
        {
            if(acr < 0)
            {
                sin_theta = -rsqrt(static_cast<T>(2));
                cos_theta = rsqrt(static_cast<T>(2));
                sin_two_theta = -one<T>;
                cos_two_theta = zero<T>;
            }
            else 
            {
                sin_theta = rsqrt(static_cast<T>(2));
                cos_theta = rsqrt(static_cast<T>(2));
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
            cos_two_theta = cos_theta * cos_theta - sin_theta * sin_theta;
        }

        T sin_theta_square = pow2(sin_theta);
        T cos_theta_square = pow2(cos_theta);
        a[col][col] = acc * cos_theta_square + arr * sin_theta_square + acr * sin_two_theta; 
        a[row][row] = acc * sin_theta_square + arr * cos_theta_square - acr * sin_two_theta;
        a[col][row] = static_cast<T>(0.5) * (arr - acc) * sin_two_theta + acr * cos_two_theta;
        a[row][col] = a[col][row];

        // givens rotate
        for(int i = 0; i < N; ++i)
        {
            if((i != col) && (i != row))
            {
                T aci = a[col][i];
                T ari = a[row][i];

                a[col][i] = cos_theta * aci + sin_theta * ari;
                a[row][i] = cos_theta * ari - sin_theta * aci;
                a[i][col] = a[col][i];
                a[i][row] = a[row][i];
            }
        }

        for(int i = 0; i < N; ++i)
        {
            T eci = eigen_vec[col][i];
            T eri = eigen_vec[row][i];

            eigen_vec[col][i] = cos_theta * eci + sin_theta * eri;
            eigen_vec[row][i] = cos_theta * eri - sin_theta * eci;
        }
    }
    eigen_value = diagonal(a);
    return { eigen_value, eigen_vec };
}

template<class M>
KTM_NOINLINE std::enable_if_t<is_floating_point_base_v<M>, svd_component<M>> decompose_svd(const M& m) noexcept
{
    using u_type = typename svd_component<M>::u_type;
    using s_type = typename svd_component<M>::s_type;
    using vt_type = typename svd_component<M>::vt_type;
    constexpr size_t row_n = mat_traits_row_n<s_type>;
    constexpr size_t col_n = mat_traits_col_n<s_type>;

    // calc matrix svd decomposition(using decompose_eigen_jacobi to decompose matrix eigenvectors and eigenvalues)
    if constexpr(row_n >= col_n)
    {
        // if row_n >= col_n, first calc v matrix
        eigen_component<vt_type> ata_eigen = decompose_eigen_jacobi(transpose(m) * m);
        mat_traits_col_t<s_type>& ata_eigen_value_ref = reinterpret_cast<mat_traits_col_t<s_type>&>(ata_eigen.get_value());
        ata_eigen_value_ref = sqrt(abs(ata_eigen_value_ref));
        s_type s; mat_traits_tp_t<s_type> inv_s;
        if constexpr(row_n == col_n)
        {
            s = s_type::from_diag(ata_eigen_value_ref);
            inv_s = s_type::from_diag(recip(ata_eigen_value_ref));
        }
        else
        {
            s = { }; inv_s = { };
            mat_traits_col_t<s_type> recip_diag_value = recip(ata_eigen_value_ref);
            for(int i = 0; i < col_n; ++i)
            {
                s[i][i] = ata_eigen_value_ref[i];
                inv_s[i][i] = recip_diag_value[i]; 
            }
        }
        vt_type& v = ata_eigen.get_vector();
        u_type u = m * v * inv_s;
        return { u, s, transpose(v) };
    }
    else
    {
        // if row_n < col_n, first calc u matrix
        eigen_component<u_type> aat_eigen = decompose_eigen_jacobi(m * transpose(m));
        u_type& u = aat_eigen.get_vector();
        mat_traits_row_t<s_type>& aat_eigen_value_ref = reinterpret_cast<mat_traits_row_t<s_type>&>(aat_eigen.get_value());
        aat_eigen_value_ref = sqrt(abs(aat_eigen_value_ref));
        s_type s { }; mat_traits_tp_t<s_type> inv_s { }; 
        mat_traits_row_t<s_type> recip_diag_value = recip(aat_eigen_value_ref);
        for(int i = 0; i < row_n; ++i)
        {
            s[i][i] = aat_eigen_value_ref[i];
            inv_s[i][i] = recip_diag_value[i];
        }
        vt_type vt = inv_s * transpose(u) * m;
        return { u, s, vt };
    }
}

template<class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, affine_component<M>> decompose_affine(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_n<M>;
    using T = mat_traits_base_t<M>;
    if constexpr(N == 2)
    {
        M translate_matrix = M::from_eye();
        translate_matrix[1][0] = m[1][0];
        M rotate_matrix = M::from_eye();
        rotate_matrix[0][0] = std::copysign(one<T>, m[0][0]);
        M scale_matrix = M::from_eye();
        scale_matrix[0][0] = abs(m[0][0]);
        return { translate_matrix, rotate_matrix, M::from_eye(), scale_matrix };
    }
    else
    {
        using AffM = mat<N - 1, N - 1, T>;
        using AffV = vec<N - 1, T>;
        constexpr auto m_to_affm_lambda = [N](const M& in_m, AffM& out_affm) -> void
        {
            for(int i = 0; i < N - 1; ++i)
                std::copy(in_m[i].begin(), in_m[i].end() - 1, out_affm[i].begin());
        };
        constexpr auto affm_to_m_lambda = [N](const AffM& in_affm, M& out_m) -> void
        {
            for(int i = 0; i < N - 1; ++i)
            {
                std::copy(in_affm[i].begin(), in_affm[i].end(), out_m[i].begin());
                out_m[i][N - 1] = zero<T>;
            }
            out_m[N - 1].fill(zero<T>); 
            out_m[N - 1][N - 1] = one<T>;
        };

        // calc matrix affine decomposition(translation * rotation * shear * scale)
        AffM affine_matrix;
        m_to_affm_lambda(m, affine_matrix);
        qr_component<AffM> affine_qr = decompose_qr_givens(affine_matrix);
        AffM& affine_rotate_ref = affine_qr.get_q();
        AffM& affine_upper_ref = affine_qr.get_r();
        AffV affine_diag_vec = diagonal(affine_upper_ref);
        mat_traits_col_t<M> diag_vec;
        for(int i = 0; i < N - 1; ++i)
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

}

#endif