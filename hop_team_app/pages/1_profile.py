import plotly.express as px
import streamlit as st
import pandas as pd

hop = pd.read_csv("data/hop_team_nashville.csv")

pcp_patient_count = hop.groupby("pcp_classification")["patient_count"].sum().reset_index()

st.write("""
# PCP Analysis
""")

fig = px.bar(
    pcp_patient_count,                         
    x="pcp_classification",          
    y="patient_count",               
    title="Top Referring Providers"
)

fig.update_layout(
    xaxis_title="Provider Classification",
    yaxis_title="Total Referrals"
)

st.plotly_chart(fig, use_container_width=True)  