import streamlit as st
import pandas as pd
import plotly.express as px

st.write("""
# Hop Team App 
""")

referral_data = pd.read_csv('data/hop_team.csv')
orgs_data = pd.read_csv('data/orgs.csv')
orgs_data['communityId'] = orgs_data['communityId'].astype(str)

st.title('Referral Communities of Middle TN')

fig = px.scatter_mapbox(
    orgs_data,
    lat="latitude",
    lon="longitude",
    hover_name="org_name",
    color = "communityId",
    zoom=7,
    height=400
)

fig.update_layout(mapbox_style="open-street-map")
fig.update_layout(margin={"r":0,"t":0,"l":0,"b":0})

st.plotly_chart(fig)

st.write(referral_data)
