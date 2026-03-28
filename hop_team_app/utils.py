import streamlit as st
import pandas as pd


# Load data
@st.cache_data
def load_data(path:str):
    data = pd.read_csv(path)
    return data

hop_team_nashville_df = load_data('data/hop_team_nashville.csv')
hop_team_community_df = load_data('data/hop_team_community.csv')

#-------------------------------------------------

# Get list of Nashville PCP Specialties
pcp_specialization_list = hop_team_nashville_df['pcp_specialization'].unique()

# Get list of Nashville Hospitals
hospital_list = hop_team_nashville_df['hospital'].unique()