import React, {type ReactNode} from 'react';
import Link from '@docusaurus/Link';
import {useBlogPost} from '@docusaurus/plugin-content-blog/client';
import Header from '@theme-original/BlogPostItem/Header';
import type HeaderType from '@theme/BlogPostItem/Header';
import type {WrapperProps} from '@docusaurus/types';

type Props = WrapperProps<typeof HeaderType>;

export default function HeaderWrapper(props: Props): ReactNode {
  const {metadata, assets, isBlogPostPage} = useBlogPost();
  const cover = assets?.image ?? metadata.frontMatter.image;
  return (
    <>
      {cover ? (
        isBlogPostPage ? (
          <img src={cover} alt="" className="blog-post-cover" />
        ) : (
          <Link to={metadata.permalink} className="blog-post-cover-link">
            <img src={cover} alt="" className="blog-post-cover" />
          </Link>
        )
      ) : null}
      <Header {...props} />
    </>
  );
}
