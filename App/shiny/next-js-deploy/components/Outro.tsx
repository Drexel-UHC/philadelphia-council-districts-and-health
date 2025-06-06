import { AnchorHeading } from "@/components/ui/anchor-heading";

export default function Outro() {
  return (
    <section id="about" className="mb-12 pt-10">
      {/* About the Data section */}
      <div className="section mb-8">
        <AnchorHeading 
          id="about-the-data" 
          level="h2"
          className="text-xl font-bold mb-3 pb-2 border-b border-gray-300"
        >
          About the Data
        </AnchorHeading>
        <p className="text-lg text-gray-700 mb-6">
          
          For full details on data sources and metric definitions and to download the data, see our
          {" "}
          <a
            href="https://zenodo.org/records/15609792"
            target="_blank"
            rel="noopener noreferrer"
            className="text-blue-600 hover:underline font-semibold"
          >
            data archive and documentation page
          </a>.
        </p>
        <p className="text-lg text-gray-700 mb-6">
          This dashboard is a work in progress. The last update took place on January 27, 2025.
        </p>
      </div>
      
      {/* Acknowledgements section */}
      <div className="section mb-8">
        <AnchorHeading 
          id="acknowledgements" 
          level="h2"
          className="text-xl font-bold mb-3 pb-2 border-b border-gray-300"
        >
          Acknowledgements
        </AnchorHeading>
        <p className="text-lg text-gray-700 mb-6">
          This dashboard was developed through collaborative effort and supported by the IDEA Fellowship.
        </p>
      </div>
      
      {/* Authors and sponsor section */}
      <div className="section mb-8">
        <h4 className="text-lg font-bold mb-2">
          Authors
        </h4>
        <p className="mb-4">Amber Bolli, Tamara Rushovich, Ran Li, Stephanie Hernandez, Alina Schnake-Mahl</p>
        
        <h4 className="text-lg font-bold mb-2">
          Sponsor
        </h4>
        <p className="mb-4">This project received funding from the Transform Academia for Equity grant from Robert Wood Johnson Foundation</p>
      </div>
      
      {/* Links to related work section */}
      <div className="section mb-8">
        <h4 className="text-lg font-bold mb-2">
          Links to Related Work
        </h4>
        <ul className="list-disc pl-5 mb-4 space-y-1">
          <li>
            <a 
              href="https://www.congressionaldistricthealthdashboard.org" 
              target="_blank" 
              rel="noopener noreferrer"
              className="hover:underline"
            >
              Congressional District Health Dashboard
            </a>
          </li>
          <li>
            <a 
              href="https://pubmed.ncbi.nlm.nih.gov/39190647/" 
              target="_blank" 
              rel="noopener noreferrer"
              className="hover:underline"
            >
              Rushovich T, Nethery RC, White A, Krieger N. Gerrymandering and the Packing and Cracking of Medical Uninsurance Rates in the United States. J Public Health Manag Pract. 2024
            </a>
          </li>
          <li>
            <a 
              href="https://pubmed.ncbi.nlm.nih.gov/38412272/" 
              target="_blank" 
              rel="noopener noreferrer"
              className="hover:underline"
            >
              Schnake-Mahl A, Anfuso G, Goldstein ND, et al. Measuring variation in infant mortality and deaths of despair by US congressional district in Pennsylvania: a methodological case study. Am J Epidemiol. 2024
            </a>
          </li>
          <li>
            <a 
              href="https://pmc.ncbi.nlm.nih.gov/articles/PMC11921522/" 
              target="_blank" 
              rel="noopener noreferrer"
              className="hover:underline"
            >
              Schnake-Mahl A, Anfuso G, Bilal U, et al. Court-mandated redistricting and disparities in infant mortality and deaths of despair. BMC Public Health. 2025
            </a>
          </li>
          <li>
            <a 
              href="https://pubmed.ncbi.nlm.nih.gov/39329432/" 
              target="_blank" 
              rel="noopener noreferrer"
              className="hover:underline"
            >
              Schnake-Mahl A, Anfuso G, Hernandez SM, Bilal U. Geospatial Data Aggregation Methods for Novel Geographies: Validating Congressional District Life Expectancy Estimates. Epidemiology. 2025
            </a>
          </li>
          <li>
            <a 
              href="https://pmc.ncbi.nlm.nih.gov/articles/PMC10498302/" 
              target="_blank" 
              rel="noopener noreferrer"
              className="hover:underline"
            >
              Spoer BR, Chen AS, Lampe TM, et al. Validation of a geospatial aggregation method for congressional districts and other US administrative geographies. SSM Popul Health. 2023
            </a>
          </li>
        </ul>
      </div>
      
      {/* Citation section */}
      <div className="section mb-8">
        <h4 className="text-lg font-bold mb-2">
          Citation
        </h4>
        <div className="bg-gray-100 p-4 rounded font-mono text-sm">
          Amber, B., Tamara, R., Ran, L., Stephanie, H., & Alina, S.-M. (2025). <em>Philadelphia Council District Health Dashboard (Dataset)</em> [Data set]. Zenodo. <a href="https://doi.org/10.5281/zenodo.15609792" target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:underline">https://doi.org/10.5281/zenodo.15609792</a>
        </div>
      </div>
      
      {/* Contact section */}
      <div className="section mb-8">
        <h4 className="text-lg font-bold mb-2">
          Contact Us
        </h4>
        <p>
          Please reach out to{" "}
          <a 
            href="mailto:UHC@drexel.edu" 
            className="hover:underline"
          >
            UHC@drexel.edu
          </a>
          {" "}with any questions.
        </p>
      </div>
    </section>
  );
}