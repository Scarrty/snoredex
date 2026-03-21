// SPDX-License-Identifier: CC-BY-NC-4.0
import { SectionPage } from '../../components/section-page';
import { sectionContent } from '../../lib/site-data';

export default function ListingsPage() {
  return <SectionPage content={sectionContent.listings} currentHref="/listings" />;
}
