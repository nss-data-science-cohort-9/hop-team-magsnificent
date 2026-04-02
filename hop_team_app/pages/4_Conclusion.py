import streamlit as st


st.set_page_config(layout="wide")

st.title('Conclusion')

st.header('Summary', divider='rainbow', text_alignment='left')

st.markdown(
    '''
    * Vanderbilt's larget areas of opportunity are within Interventional Cardiology and Pulmonary Disease.
    * Vanderbilt's share of the Cardiovascular Disease referrals is 39.1% (72,422 / 185,209)
    * The number of Vanderbilt's communities is 3 whereas HCA has 7 and Saint Thomas are part of 4.
    '''
)

st.space('large')

st.header('Recommendations', divider='rainbow', text_alignment='left')

st.markdown(
    '''
    * Find ways to increase referrals from PCP's with specialties in Interventional Cardiology and Pulmonary Disease.
    * Find ways to increase the share of specialties that Vanderbilt is strong in.
    * Find way to reach further out in Middle TN.
    '''
)