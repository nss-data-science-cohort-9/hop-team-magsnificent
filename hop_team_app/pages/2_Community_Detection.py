import streamlit as st

st.title('Community Detection')

'''
Community detection is a mechanism that clusters nodes in the network into groups such that nodes in each group are more densely connected internally than externally. Community detection can be either centralized or distributed, depending on whether the whole network graph is required or only a part of it is required by the entity that performs the community detection. Because networks are an integral part of many real-world problems, community detection algorithms have found their way into various fields, ranging from social network analysis to public health initiatives. Community detection algorithms are used to evaluate how groups of nodes are clustered or partitioned, as well as their tendency to strengthen or break apart.

'''

st.header('Louvain')

'''
The Louvain method is an algorithm to detect communities in large networks. It maximizes a modularity score for each community, where the modularity quantifies the quality of an assignment of nodes to communities. This means evaluating how much more densely connected the nodes within a community are, compared to how connected they would be in a random network.

The Louvain algorithm is a hierarchical clustering algorithm, that recursively merges communities into a single node and executes the modularity clustering on the condensed graphs.
'''

st.image('images/community_detection.jpg')