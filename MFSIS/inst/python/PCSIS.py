import numpy as np
def get_arccos_1d(X):
    # X is a 1-d array
    """  Get a intermediate statistic about projection correlation
    :param X: A column from design matrix X of dimensions n * p  or the response vector Y.
    :return: np.array
    """
    X = np.squeeze(X)
    Y = X[:, None] - X
    Z = Y.T[:, :, None] * Y.T[:, None]
    n = len(X)

    a = np.zeros([n, n, n])
    a[Z == 0.] = np.pi / 2.
    a[Z < 0.] = np.pi

    a = np.transpose(a, (1, 2, 0))

    a_bar_12 = np.mean(a, axis=0, keepdims=True)
    a_bar_02 = np.mean(a, axis=1, keepdims=True)
    a_bar_2 = np.mean(a, axis=(0, 1), keepdims=True)
    A = a - a_bar_12 - a_bar_02 + a_bar_2

    return A

def projection_corr_1d(A_x,A_y,n):
    '''
     The sample projection correlation between A_x and A_y is defined as the square root of PC(A_y,A_y)
    :param A_x: the predictor
    :param A_y: the response
    :param n: the sample size
    :return: np.array
    '''
    S_xy = np.sum(A_x * A_y) / (n ** 3)
    S_xx = np.sum(A_x ** 2) / (n ** 3)
    S_yy = np.sum(A_y ** 2) / (n ** 3)

    if S_xx * S_yy == 0.:
        corr = 0.
    else:
        corr = np.sqrt(S_xy / np.sqrt(S_xx * S_yy))

    return corr