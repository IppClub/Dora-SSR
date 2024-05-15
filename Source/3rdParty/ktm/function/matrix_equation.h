//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_MATRIX_EQUATION_H_
#define _KTM_MATRIX_EQUATION_H_

#include <tuple>
#include "../setup.h"
#include "../type/basic.h"
#include "../traits/type_traits_math.h"
#include "matrix.h"
#include "epsilon.h"
#include "trigonometric.h"

namespace ktm
{

template<class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, std::tuple<M, M>> factor_lu(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_n<M>;

    // calc matrix lu decomposition
    M l = M::from_eye(), u { };

    // u[i][0] = m[i][0]
    // l[0][j] = m[0][j] / u[0][0]
    for(int i = 0; i < N; ++i)
    {
        u[i][0] = m[i][0];
        l[0][i] = m[0][i] / u[0][0];
    }

    for (int i = 1; i < N; i++)
    {
        //                     \- j-1
        // u[i][j] = m[i][j] - |  l[k][j] * u[i][k]
        //                     /- k=0
        for(int j = 1; j <= i; ++j)
        {
            u[i][j] = m[i][j];
            for(int k = 0; k < j; ++k)
            {
                u[i][j] -= l[k][j] * u[i][k];
            }
        }

        //                     \- i-1
        // l[i][j] = m[i][j] - |  l[k][j] * u[i][k] / u[i][i]
        //                     /- k=0
        for(int j = i + 1; j < N; ++j)
        {
            l[i][j] = m[i][j];
            for(int k = 0; k < i; ++k)
            {
                l[i][j] -= l[k][j] * u[i][k];
            }
            l[i][j] /= u[i][i];
        }
    }
    return { l, u };
}

template<class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, std::tuple<M, M>> factor_qr(const M& m) noexcept
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
        alpha = r[i][i] > zero<T> ? -sqrt(alpha) : sqrt(alpha);

        T r_rho = rsqrt(static_cast<T>(2) * alpha * (alpha - r[i][i]));
        r[i][i] = (r[i][i] - alpha) * r_rho;
        for(int j = i + 1; j < N; ++j)
        {
            r[i][j] *= r_rho;
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
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, std::tuple<mat_traits_col_t<M>, M>> eigen_qrit(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_n<M>;

    // qr iteration for calc matrix eigenvectors and eigenvalues
    M a { m }, eigen_vec = M::from_eye();
    mat_traits_col_t<M> eigen_value, last_eigen_value;

    for(int i = 0; i < N; ++i)
    {
        eigen_value[i] = a[i][i]; 
    }
    
    for(int it = 0; it < 100; ++it) 
    {
        last_eigen_value = eigen_value;
        std::tuple<M, M> qr = factor_qr(a);
        a = std::get<1>(qr) * std::get<0>(qr);
        eigen_vec = eigen_vec * std::get<0>(qr);

        for(int i = 0; i < N; ++i)
        {
            eigen_value[i] = a[i][i]; 
        }
        if(equal(eigen_value, last_eigen_value))
            break;
    }
    return { eigen_value, eigen_vec };
}

template<class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, std::tuple<mat_traits_col_t<M>, M>> eigen_jacobi(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_n<M>;
    using T = mat_traits_base_t<M>;

    // jacobi iteration for matrix eigenvectors and eigenvalues(the matrix must be a symmetric matrix)
    M a { m }, eigen_vec = M::from_eye();
    mat_traits_col_t<M> eigen_value;

    for(int it = 0; it < 100; ++it)
    {
        // find the maximum element on a non diagonal line
        int col = 0, row = 1;
        T nd_max = abs(a[0][1]);
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
        T sin_theta, cos_theta, sin_2theta, cos_2theta;

        if(equal(arr, acc))
        {
            if(acr < 0)
            {
                sin_theta = -rsqrt(static_cast<T>(2));
                cos_theta = rsqrt(static_cast<T>(2));
                sin_2theta = -one<T>;
                cos_2theta = zero<T>;
            }
            else 
            {
                sin_theta = rsqrt(static_cast<T>(2));
                cos_theta = rsqrt(static_cast<T>(2));
                sin_2theta = one<T>;
                cos_2theta = zero<T>; 
            }
        }
        else
        {
            T theta = static_cast<T>(0.5) * atan2(static_cast<T>(2) * acr, arr - acc);
            sin_theta = sin(theta);
            cos_theta = cos(theta);
            sin_2theta = sin(static_cast<T>(2) * theta);
            cos_2theta = cos(static_cast<T>(2) * theta);
        }

        // calc matrix element
        a[col][col] = arr * sin_theta * sin_theta + acc * cos_theta * cos_theta + acr * sin_2theta; 
        a[row][row] = arr * cos_theta * cos_theta + acc * sin_theta * sin_theta + acr * sin_2theta;
        a[col][row] = static_cast<T>(0.5) * (acc - arr) * sin_2theta + acr * cos_2theta;
        a[row][col] = a[col][row];

        for(int i = 0; i < N; ++i)
        {
            if((i != col) && (i != row))
            {
                T aci = a[col][i];
                T ari = a[row][i];

                a[col][i] = cos_theta * aci - sin_theta * ari;
                a[row][i] = cos_theta * ari + sin_theta * aci;
                a[i][col] = a[col][i];
                a[i][row] = a[row][i];
            }
        }

        // calc eigenvectors
        for(int i = 0; i < N; ++i)
        {
            T eci = eigen_vec[col][i];
            T eri = eigen_vec[row][i];

            eigen_vec[col][i] = cos_theta * eci - sin_theta * eri;
            eigen_vec[row][i] = cos_theta * eri + sin_theta * eci;
        }
    }

    for(int i = 0; i < N; ++i)
    {
        eigen_value[i] = a[i][i];
    }

    return { eigen_value, eigen_vec };
}

template<class M>
KTM_NOINLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, std::tuple<M, M, M>> factor_svd(const M& m) noexcept
{
    constexpr size_t N = mat_traits_col_n<M>;

    // calc matrix SVD decomposition(using eigen_jacobi to find matrix eigenvectors and eigenvalues)
    std::tuple<mat_traits_col_t<M>, M> ata_eigen = eigen_jacobi(transpose(m) * m);
    mat_traits_col_t<M>& ata_eigen_value_ref = std::get<0>(ata_eigen);

    for(int i = 0; i < N; ++i)
    {
        ata_eigen_value_ref[i] = sqrt(abs(ata_eigen_value_ref[i])); 
    }
    M v = transpose(std::get<1>(ata_eigen));
    M s = M::from_diag(ata_eigen_value_ref);
    for(int i = 0; i < N; ++i)
    {
        ata_eigen_value_ref[i] = recip(ata_eigen_value_ref[i]);  
    }
    M u = m * std::get<1>(ata_eigen) * M::from_diag(ata_eigen_value_ref);
    return { u, s, v };
}

}

#endif