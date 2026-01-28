import pandas as pd
import numpy as np
from scipy import sparse
from sklearn.decomposition import TruncatedSVD

RATINGS_CSV = "ratings.csv"
D = 64                    # embedding dimension
MAX_USERS = 5000          
MAX_MOVIES = 10000

OUT_UW = "uw.csv"
OUT_MW = "mw.csv"

ratings = pd.read_csv(RATINGS_CSV, usecols=["userId","movieId","rating"])

# sample
if MAX_USERS is not None:
    users = ratings["userId"].drop_duplicates().head(MAX_USERS)
    ratings = ratings[ratings["userId"].isin(users)]
if MAX_MOVIES is not None:
    movies = ratings["movieId"].drop_duplicates().head(MAX_MOVIES)
    ratings = ratings[ratings["movieId"].isin(movies)]

# 0..n-1
u_ids = ratings["userId"].unique()
m_ids = ratings["movieId"].unique()
u_map = {u:i for i,u in enumerate(u_ids)}
m_map = {m:i for i,m in enumerate(m_ids)}

ui = ratings["userId"].map(u_map).to_numpy()
mi = ratings["movieId"].map(m_map).to_numpy()
rv = ratings["rating"].to_numpy(dtype=np.float32)

R = sparse.coo_matrix((rv, (ui, mi)), shape=(len(u_ids), len(m_ids))).tocsr()

# R ≈ U * S * Vt
svd = TruncatedSVD(n_components=D, random_state=0)
U_S = svd.fit_transform(R)        # (n_users, D)
Vt = svd.components_              # (D, n_movies)

M_vec = Vt.T.astype(np.float32)   # (n_movies, D)
U_vec = U_S.astype(np.float32)    # (n_users, D)

def vec_to_str(v):
    return "[" + ",".join(f"{x:.6f}" for x in v) + "]"

uw = pd.DataFrame({
    "U": [f"u{u}" for u in u_ids],
    "F": [vec_to_str(U_vec[i]) for i in range(len(u_ids))]
})
mw = pd.DataFrame({
    "M": [f"m{m}" for m in m_ids],
    "G": [vec_to_str(M_vec[i]) for i in range(len(m_ids))]
})

uw.to_csv(OUT_UW, index=False, header=False)
mw.to_csv(OUT_MW, index=False, header=False)

print("Wrote:", OUT_UW, OUT_MW, "users:", len(uw), "movies:", len(mw), "dim:", D)

