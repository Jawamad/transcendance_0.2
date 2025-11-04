import { ethers } from "hardhat";

async function main() {
  // Récupère le "factory" (constructeur) du contrat
  const MyContract = await ethers.getContractFactory("MyContract");

  // Déploie le contrat (ajoute des arguments ici si ton constructeur en a)
  const myContract = await MyContract.deploy();

  // Attend que le contrat soit déployé sur le réseau
  await myContract.waitForDeployment();

  // Affiche l'adresse du contrat
  console.log("✅ MyContract déployé à :", await myContract.getAddress());
}

// Lancement du script avec gestion d’erreur propre
main().catch((error) => {
  console.error("❌ Erreur de déploiement :", error);
  process.exitCode = 1;
});
