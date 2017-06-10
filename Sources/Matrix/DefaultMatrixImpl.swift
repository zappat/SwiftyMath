//
//  DefaultMatrixImpl.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/06/10.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

// General Ring

public extension Ring {
    public static func matrixImplType(_ type: MatrixType) -> _MatrixImpl<Self>.Type {
        switch type {
        case .Default:
            return _GridMatrixImpl<Self>.self
        case .Sparse:
            return _SparseMatrixImpl<Self>.self
        }
    }
    
    public static func matrixEliminationProcessorType() -> MatrixEliminationProcessor<Self>.Type {
        fatalError("Matrix elimination not supported for a general Ring.")
    }
}

// EuclideanRing

public extension EuclideanRing {
    public static func matrixEliminationProcessorType() -> MatrixEliminationProcessor<Self>.Type {
        return EucMatrixEliminationProcessor<Self>.self
    }
}

// Field

public extension Field {
    public static func matrixEliminationProcessorType() -> MatrixEliminationProcessor<Self>.Type {
        return FieldMatrixEliminationProcessor<Self>.self
    }
}